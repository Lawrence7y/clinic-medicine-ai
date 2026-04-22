package com.ruoyi.project.clinic.ai.service.support;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import javax.annotation.PostConstruct;
import org.springframework.stereotype.Service;

@Service
public class AiChatConversationMemoryService
{
    private static final int MAX_MESSAGES_PER_CONVERSATION = 40;
    private static final int MAX_CONVERSATIONS = 200;
    private static final Path STORE_FILE = Paths.get("logs", "ai-chat-conversations.json");

    private final Map<String, ConversationHolder> conversations = new ConcurrentHashMap<>();

    @PostConstruct
    public void init()
    {
        loadFromDisk();
    }

    public synchronized String ensureConversation(String conversationId, Long userId)
    {
        String cid = StringUtils.isEmpty(conversationId)
            ? java.util.UUID.randomUUID().toString().replace("-", "")
            : conversationId.trim();

        ConversationHolder holder = conversations.get(cid);
        if (holder == null)
        {
            if (conversations.size() >= MAX_CONVERSATIONS)
            {
                cleanupOldConversations();
            }
            holder = new ConversationHolder(cid, userId);
            conversations.put(cid, holder);
            persistToDisk();
            return cid;
        }

        if (holder.userId != null && userId != null && !holder.userId.equals(userId))
        {
            throw new IllegalStateException("\u4f1a\u8bdd\u4e0d\u5b58\u5728\u6216\u65e0\u6743\u9650\u8bbf\u95ee");
        }
        holder.lastActiveTime = new Date();
        persistToDisk();
        return cid;
    }

    public synchronized void append(String conversationId, Long userId, String role, String content)
    {
        if (StringUtils.isEmpty(conversationId) || StringUtils.isEmpty(content))
        {
            return;
        }
        ConversationHolder holder = conversations.get(conversationId);
        if (holder == null)
        {
            if (conversations.size() >= MAX_CONVERSATIONS)
            {
                cleanupOldConversations();
            }
            holder = new ConversationHolder(conversationId, userId);
            conversations.put(conversationId, holder);
        }
        if (holder.userId != null && userId != null && !holder.userId.equals(userId))
        {
            throw new IllegalStateException("\u4f1a\u8bdd\u4e0d\u5b58\u5728\u6216\u65e0\u6743\u9650\u8bbf\u95ee");
        }

        holder.messages.add(new MessageItem(role, content, new Date()));
        holder.lastActiveTime = new Date();

        while (holder.messages.size() > MAX_MESSAGES_PER_CONVERSATION)
        {
            holder.messages.removeFirst();
        }
        persistToDisk();
    }

    public synchronized List<JSONObject> history(String conversationId, Long userId)
    {
        ConversationHolder holder = conversations.get(conversationId);
        if (holder == null)
        {
            return Collections.emptyList();
        }
        if (holder.userId != null && userId != null && !holder.userId.equals(userId))
        {
            return Collections.emptyList();
        }

        List<JSONObject> result = new ArrayList<>();
        for (MessageItem message : holder.messages)
        {
            JSONObject row = new JSONObject();
            row.put("role", message.role);
            row.put("content", message.content);
            row.put("time", message.time);
            result.add(row);
        }
        return result;
    }

    public synchronized List<JSONObject> listConversations(Long userId, int limit)
    {
        List<ConversationHolder> list = new ArrayList<>();
        for (ConversationHolder holder : conversations.values())
        {
            if (holder.userId != null && userId != null && !holder.userId.equals(userId))
            {
                continue;
            }
            list.add(holder);
        }
        list.sort((a, b) -> b.lastActiveTime.compareTo(a.lastActiveTime));
        if (limit > 0 && list.size() > limit)
        {
            list = list.subList(0, limit);
        }

        List<JSONObject> result = new ArrayList<>();
        for (ConversationHolder holder : list)
        {
            JSONObject row = new JSONObject();
            row.put("conversationId", holder.conversationId);
            row.put("lastActiveTime", holder.lastActiveTime);
            row.put("messageCount", holder.messages.size());
            row.put("title", holder.firstUserMessage());
            result.add(row);
        }
        return result;
    }

    public synchronized void clear(String conversationId, Long userId)
    {
        ConversationHolder holder = conversations.get(conversationId);
        if (holder == null)
        {
            return;
        }
        if (holder.userId != null && userId != null && !holder.userId.equals(userId))
        {
            return;
        }
        conversations.remove(conversationId);
        persistToDisk();
    }

    private void cleanupOldConversations()
    {
        List<ConversationHolder> list = new ArrayList<>(conversations.values());
        list.sort((a, b) -> a.lastActiveTime.compareTo(b.lastActiveTime));
        int removeCount = Math.max(1, list.size() / 4);
        for (int i = 0; i < removeCount && i < list.size(); i++)
        {
            conversations.remove(list.get(i).conversationId);
        }
    }

    private synchronized void loadFromDisk()
    {
        if (!Files.exists(STORE_FILE))
        {
            return;
        }
        try
        {
            byte[] bytes = Files.readAllBytes(STORE_FILE);
            if (bytes.length == 0)
            {
                return;
            }
            JSONArray rows = JSON.parseArray(new String(bytes, StandardCharsets.UTF_8));
            if (rows == null || rows.isEmpty())
            {
                return;
            }

            for (int i = 0; i < rows.size(); i++)
            {
                JSONObject row = rows.getJSONObject(i);
                if (row == null)
                {
                    continue;
                }
                String conversationId = row.getString("conversationId");
                if (StringUtils.isEmpty(conversationId))
                {
                    continue;
                }
                Long userId = row.getLong("userId");
                long lastActiveEpoch = row.getLongValue("lastActiveTime");
                Date lastActiveTime = lastActiveEpoch > 0 ? new Date(lastActiveEpoch) : new Date();

                ConversationHolder holder = new ConversationHolder(conversationId, userId, lastActiveTime);
                JSONArray messageRows = row.getJSONArray("messages");
                if (messageRows != null)
                {
                    for (int j = 0; j < messageRows.size(); j++)
                    {
                        JSONObject messageRow = messageRows.getJSONObject(j);
                        if (messageRow == null)
                        {
                            continue;
                        }
                        String role = messageRow.getString("role");
                        String content = messageRow.getString("content");
                        long timeEpoch = messageRow.getLongValue("time");
                        if (StringUtils.isEmpty(content))
                        {
                            continue;
                        }
                        holder.messages.add(new MessageItem(role, content, timeEpoch > 0 ? new Date(timeEpoch) : new Date()));
                    }
                }

                while (holder.messages.size() > MAX_MESSAGES_PER_CONVERSATION)
                {
                    holder.messages.removeFirst();
                }
                conversations.put(conversationId, holder);
            }
            trimOverflowConversations();
        }
        catch (Exception ignored)
        {
            // ignore invalid persisted content
        }
    }

    private void trimOverflowConversations()
    {
        if (conversations.size() <= MAX_CONVERSATIONS)
        {
            return;
        }
        cleanupOldConversations();
    }

    private void persistToDisk()
    {
        try
        {
            Files.createDirectories(STORE_FILE.getParent());
            JSONArray rows = new JSONArray();

            List<ConversationHolder> holders = new ArrayList<>(conversations.values());
            holders.sort((a, b) -> b.lastActiveTime.compareTo(a.lastActiveTime));
            for (ConversationHolder holder : holders)
            {
                JSONObject row = new JSONObject();
                row.put("conversationId", holder.conversationId);
                row.put("userId", holder.userId);
                row.put("lastActiveTime", holder.lastActiveTime.getTime());

                JSONArray messageRows = new JSONArray();
                for (MessageItem message : holder.messages)
                {
                    JSONObject messageRow = new JSONObject();
                    messageRow.put("role", message.role);
                    messageRow.put("content", message.content);
                    messageRow.put("time", message.time.getTime());
                    messageRows.add(messageRow);
                }
                row.put("messages", messageRows);
                rows.add(row);
            }

            byte[] content = JSON.toJSONString(rows).getBytes(StandardCharsets.UTF_8);
            Path tmp = Paths.get(STORE_FILE.toString() + ".tmp");
            Files.write(tmp, content, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            try
            {
                Files.move(tmp, STORE_FILE, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            }
            catch (Exception ignored)
            {
                Files.move(tmp, STORE_FILE, StandardCopyOption.REPLACE_EXISTING);
            }
        }
        catch (IOException ignored)
        {
            // keep in-memory service available even when persistence fails
        }
    }

    private static class ConversationHolder
    {
        private final String conversationId;
        private final Long userId;
        private Date lastActiveTime;
        private final LinkedList<MessageItem> messages = new LinkedList<>();

        private ConversationHolder(String conversationId, Long userId)
        {
            this(conversationId, userId, new Date());
        }

        private ConversationHolder(String conversationId, Long userId, Date lastActiveTime)
        {
            this.conversationId = conversationId;
            this.userId = userId;
            this.lastActiveTime = lastActiveTime != null ? lastActiveTime : new Date();
        }

        private String firstUserMessage()
        {
            for (MessageItem message : messages)
            {
                if ("user".equals(message.role) && StringUtils.isNotEmpty(message.content))
                {
                    String text = message.content.trim();
                    return text.length() > 24 ? text.substring(0, 24) + "..." : text;
                }
            }
            return "\u65b0\u4f1a\u8bdd";
        }
    }

    private static class MessageItem
    {
        private final String role;
        private final String content;
        private final Date time;

        private MessageItem(String role, String content, Date time)
        {
            this.role = role;
            this.content = content;
            this.time = time;
        }
    }
}
