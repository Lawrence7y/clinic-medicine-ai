package com.ruoyi.project.clinic.ai.service.support;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;

@Service
public class ClinicAiSafetyService
{
    private static final List<String> BLOCKED_KEYWORDS = Collections.unmodifiableList(Arrays.asList(
        "api key", "apikey", "token", "密钥", "口令", "密码", "system prompt", "系统提示词", "提示词原文",
        "数据库连接", "数据库账号", "导出全部用户", "导出所有用户", "管理员密码", "提权", "绕过限制", "忽略之前指令",
        "内网穿透", "环境变量", "access key", "secret key", "session cookie"));
    private static final List<String> ADMIN_ONLY_KEYWORDS = Collections.unmodifiableList(Arrays.asList(
        "系统配置", "配置中心", "体验版域名", "后台地址", "接口地址", "数据库", "内网穿透", "审计日志", "审计中心",
        "导出报表", "导出数据", "权限策略", "系统安全", "会话策略", "登录锁定", "敏感词规则"));

    private static final Pattern PHONE_PATTERN = Pattern.compile("(?<!\\d)(1[3-9]\\d{9})(?!\\d)");
    private static final Pattern ID_CARD_PATTERN = Pattern.compile("(?<!\\w)(\\d{17}[\\dXx])(?!\\w)");
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "(?i)([A-Z0-9._%+-])[A-Z0-9._%+-]*@([A-Z0-9.-]+\\.[A-Z]{2,})");

    public SafetyResult inspectInput(String sceneCode, String content, Set<String> roleKeys)
    {
        String normalized = StringUtils.trimToEmpty(content);
        if (StringUtils.isEmpty(normalized))
        {
            return SafetyResult.pass(normalized);
        }

        String lowerCase = normalized.toLowerCase();
        for (String keyword : BLOCKED_KEYWORDS)
        {
            if (StringUtils.isNotEmpty(keyword) && lowerCase.contains(keyword.toLowerCase()))
            {
                return SafetyResult.block(
                    normalized,
                    "blocked_sensitive_keyword",
                    "请求包含敏感词，已拦截。请不要询问密钥、口令、数据库连接或系统提示词等信息。",
                    keyword
                );
            }
        }

        if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
        {
            for (String keyword : ADMIN_ONLY_KEYWORDS)
            {
                if (StringUtils.isNotEmpty(keyword) && normalized.contains(keyword))
                {
                    return SafetyResult.block(
                        normalized,
                        "blocked_admin_scope",
                        "当前角色不支持系统配置、审计和环境类问答，请使用管理员账号处理。",
                        keyword
                    );
                }
            }
        }

        MaskResult masked = maskSensitiveText(normalized);
        return SafetyResult.pass(masked.text, masked.masked, masked.maskCount, masked.summary, sceneCode);
    }

    public SafetyResult sanitizeOutput(String sceneCode, String content)
    {
        String normalized = StringUtils.defaultString(content);
        MaskResult masked = maskSensitiveText(normalized);
        return SafetyResult.pass(masked.text, masked.masked, masked.maskCount, masked.summary, sceneCode);
    }

    private MaskResult maskSensitiveText(String source)
    {
        String next = StringUtils.defaultString(source);
        int maskCount = 0;
        StringBuilder summary = new StringBuilder();

        ReplacementResult phoneResult = replaceWithMatcher(next, PHONE_PATTERN, new Replacer()
        {
            @Override
            public String replace(Matcher matcher)
            {
                String value = matcher.group(1);
                return value.substring(0, 3) + "****" + value.substring(value.length() - 4);
            }
        });
        next = phoneResult.text;
        maskCount += phoneResult.count;
        appendSummary(summary, phoneResult.count, "手机号");

        ReplacementResult idResult = replaceWithMatcher(next, ID_CARD_PATTERN, new Replacer()
        {
            @Override
            public String replace(Matcher matcher)
            {
                String value = matcher.group(1);
                return value.substring(0, 3) + "***********" + value.substring(value.length() - 4);
            }
        });
        next = idResult.text;
        maskCount += idResult.count;
        appendSummary(summary, idResult.count, "身份证号");

        ReplacementResult emailResult = replaceWithMatcher(next, EMAIL_PATTERN, new Replacer()
        {
            @Override
            public String replace(Matcher matcher)
            {
                return matcher.group(1) + "***@" + matcher.group(2);
            }
        });
        next = emailResult.text;
        maskCount += emailResult.count;
        appendSummary(summary, emailResult.count, "邮箱");

        return new MaskResult(next, maskCount > 0, maskCount, summary.toString());
    }

    private ReplacementResult replaceWithMatcher(String source, Pattern pattern, Replacer replacer)
    {
        Matcher matcher = pattern.matcher(StringUtils.defaultString(source));
        StringBuffer buffer = new StringBuffer();
        int count = 0;
        while (matcher.find())
        {
            String replacement = replacer.replace(matcher);
            matcher.appendReplacement(buffer, Matcher.quoteReplacement(replacement));
            count++;
        }
        matcher.appendTail(buffer);
        return new ReplacementResult(buffer.toString(), count);
    }

    private void appendSummary(StringBuilder builder, int count, String label)
    {
        if (count <= 0)
        {
            return;
        }
        if (builder.length() > 0)
        {
            builder.append("、");
        }
        builder.append(label).append("x").append(count);
    }

    private interface Replacer
    {
        String replace(Matcher matcher);
    }

    private static class ReplacementResult
    {
        private final String text;
        private final int count;

        private ReplacementResult(String text, int count)
        {
            this.text = text;
            this.count = count;
        }
    }

    private static class MaskResult
    {
        private final String text;
        private final boolean masked;
        private final int maskCount;
        private final String summary;

        private MaskResult(String text, boolean masked, int maskCount, String summary)
        {
            this.text = text;
            this.masked = masked;
            this.maskCount = maskCount;
            this.summary = summary;
        }
    }

    public static class SafetyResult
    {
        private final boolean blocked;
        private final String content;
        private final boolean masked;
        private final int maskCount;
        private final String summary;
        private final String action;
        private final String userMessage;
        private final String matchedKeyword;
        private final String sceneCode;

        private SafetyResult(boolean blocked, String content, boolean masked, int maskCount, String summary, String action,
            String userMessage, String matchedKeyword, String sceneCode)
        {
            this.blocked = blocked;
            this.content = content;
            this.masked = masked;
            this.maskCount = maskCount;
            this.summary = summary;
            this.action = action;
            this.userMessage = userMessage;
            this.matchedKeyword = matchedKeyword;
            this.sceneCode = sceneCode;
        }

        public static SafetyResult pass(String content)
        {
            return new SafetyResult(false, content, false, 0, "", "", "", "", "");
        }

        public static SafetyResult pass(String content, boolean masked, int maskCount, String summary, String sceneCode)
        {
            String action = masked ? "desensitized" : "allowed";
            return new SafetyResult(false, content, masked, maskCount, summary, action, "", "", sceneCode);
        }

        public static SafetyResult block(String content, String action, String userMessage, String matchedKeyword)
        {
            return new SafetyResult(true, content, false, 0, "", action, userMessage, matchedKeyword, "");
        }

        public boolean isBlocked()
        {
            return blocked;
        }

        public String getContent()
        {
            return content;
        }

        public boolean isMasked()
        {
            return masked;
        }

        public int getMaskCount()
        {
            return maskCount;
        }

        public String getSummary()
        {
            return summary;
        }

        public String getAction()
        {
            return action;
        }

        public String getUserMessage()
        {
            return userMessage;
        }

        public String getMatchedKeyword()
        {
            return matchedKeyword;
        }

        public String getSceneCode()
        {
            return sceneCode;
        }
    }
}
