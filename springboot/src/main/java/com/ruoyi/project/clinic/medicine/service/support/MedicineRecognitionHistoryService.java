package com.ruoyi.project.clinic.medicine.service.support;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionCandidate;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionResult;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class MedicineRecognitionHistoryService
{
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private final Path imageDir = Paths.get("logs", "medicine-recognition");
    private final Path historyLog = Paths.get("logs", "medicine-recognition-history.log");

    public void recordRecognition(MedicineRecognitionResult result, String imageFileName)
    {
        List<String> imagePaths = new ArrayList<String>();
        if (imageFileName != null && !imageFileName.trim().isEmpty())
        {
            imagePaths.add(imageFileName);
        }
        recordRecognition(result, imagePaths);
    }

    public void recordRecognition(MedicineRecognitionResult result, List<String> imagePaths)
    {
        if (result == null || result.getSessionId() == null)
        {
            return;
        }
        JSONObject item = new JSONObject();
        item.put("sessionId", result.getSessionId());
        item.put("time", FORMATTER.format(LocalDateTime.now()));
        item.put("scene", result.getScene());
        item.put("source", result.getSource());
        item.put("imagePath", firstImagePath(imagePaths));
        item.put("imagePaths", toImageArray(imagePaths));
        item.put("imageCount", imagePaths != null ? imagePaths.size() : 0);
        item.put("recognizedText", result.getRecognizedText());
        item.put("candidates", toCandidateArray(result.getCandidates()));
        item.put("warnings", result.getWarnings());
        item.put("finalPayload", null);
        upsert(item);
    }

    public void recordConfirmation(String sessionId, JSONObject finalPayload)
    {
        if (sessionId == null || sessionId.trim().isEmpty())
        {
            return;
        }
        JSONObject item = findBySessionId(sessionId);
        if (item == null)
        {
            item = new JSONObject();
            item.put("sessionId", sessionId);
            item.put("time", FORMATTER.format(LocalDateTime.now()));
        }
        item.put("finalPayload", finalPayload);
        upsert(item);
    }

    public String saveImage(String sessionId, byte[] fileBytes, String contentType) throws IOException
    {
        Files.createDirectories(imageDir);
        String ext = resolveExt(contentType);
        Path file = imageDir.resolve(sessionId + ext);
        Files.write(file, fileBytes, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        return file.toString().replace("\\", "/");
    }

    public List<String> saveImages(String sessionId, List<ImagePayload> images) throws IOException
    {
        Files.createDirectories(imageDir);
        List<String> paths = new ArrayList<String>();
        if (images == null)
        {
            return paths;
        }
        for (int i = 0; i < images.size(); i++)
        {
            ImagePayload item = images.get(i);
            if (item == null || item.getBytes() == null || item.getBytes().length == 0)
            {
                continue;
            }
            String ext = resolveExt(item.getContentType());
            Path file = imageDir.resolve(sessionId + "_" + (i + 1) + ext);
            Files.write(file, item.getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            paths.add(file.toString().replace("\\", "/"));
        }
        return paths;
    }

    public List<JSONObject> latest(int limit)
    {
        List<JSONObject> items = readAll();
        Collections.reverse(items);
        if (items.size() <= limit)
        {
            return items;
        }
        return new ArrayList<JSONObject>(items.subList(0, limit));
    }

    public JSONObject loadImageData(String sessionId)
    {
        if (sessionId == null || sessionId.trim().isEmpty())
        {
            return null;
        }
        JSONObject item = findBySessionId(sessionId);
        if (item == null)
        {
            return null;
        }

        JSONArray imagePaths = item.getJSONArray("imagePaths");
        if (imagePaths == null || imagePaths.isEmpty())
        {
            String imagePath = item.getString("imagePath");
            if (imagePath != null && !imagePath.trim().isEmpty())
            {
                imagePaths = new JSONArray();
                imagePaths.add(imagePath);
            }
        }
        if (imagePaths == null || imagePaths.isEmpty())
        {
            return null;
        }

        JSONArray images = new JSONArray();
        for (int i = 0; i < imagePaths.size(); i++)
        {
            String imagePath = imagePaths.getString(i);
            JSONObject data = loadSingleImageData(sessionId, imagePath);
            if (data != null)
            {
                images.add(data);
            }
        }
        if (images.isEmpty())
        {
            return null;
        }

        JSONObject payload = new JSONObject();
        payload.put("sessionId", sessionId);
        payload.put("imagePath", images.getJSONObject(0).getString("imagePath"));
        payload.put("contentType", images.getJSONObject(0).getString("contentType"));
        payload.put("imageBase64", images.getJSONObject(0).getString("imageBase64"));
        payload.put("images", images);
        return payload;
    }

    private JSONObject loadSingleImageData(String sessionId, String imagePath)
    {
        if (imagePath == null || imagePath.trim().isEmpty())
        {
            return null;
        }
        Path imageFile = Paths.get(imagePath);
        if (!Files.exists(imageFile))
        {
            return null;
        }

        try
        {
            byte[] bytes = Files.readAllBytes(imageFile);
            JSONObject data = new JSONObject();
            data.put("sessionId", sessionId);
            data.put("imagePath", imagePath);
            data.put("contentType", resolveContentType(imagePath));
            data.put("imageBase64", Base64.getEncoder().encodeToString(bytes));
            return data;
        }
        catch (IOException ignored)
        {
            return null;
        }
    }

    private JSONArray toCandidateArray(List<MedicineRecognitionCandidate> candidates)
    {
        JSONArray array = new JSONArray();
        if (candidates == null)
        {
            return array;
        }
        for (MedicineRecognitionCandidate candidate : candidates)
        {
            JSONObject item = new JSONObject();
            item.put("candidateId", candidate.getCandidateId());
            item.put("medicineId", candidate.getMedicineId());
            item.put("name", candidate.getName());
            item.put("barcode", candidate.getBarcode());
            item.put("specification", candidate.getSpecification());
            item.put("manufacturer", candidate.getManufacturer());
            item.put("dosageForm", candidate.getDosageForm());
            item.put("form", candidate.getForm());
            item.put("category", candidate.getCategory());
            item.put("storage", candidate.getStorage());
            item.put("pharmacology", candidate.getPharmacology());
            item.put("indications", candidate.getIndications());
            item.put("dosage", candidate.getDosage());
            item.put("sideEffects", candidate.getSideEffects());
            item.put("confidence", candidate.getConfidence());
            item.put("evidenceUrls", candidate.getEvidenceUrls());
            array.add(item);
        }
        return array;
    }

    private JSONArray toImageArray(List<String> imagePaths)
    {
        JSONArray array = new JSONArray();
        if (imagePaths == null)
        {
            return array;
        }
        for (String imagePath : imagePaths)
        {
            if (imagePath != null && !imagePath.trim().isEmpty())
            {
                array.add(imagePath);
            }
        }
        return array;
    }

    private String firstImagePath(List<String> imagePaths)
    {
        if (imagePaths == null || imagePaths.isEmpty())
        {
            return null;
        }
        return imagePaths.get(0);
    }

    private synchronized void upsert(JSONObject item)
    {
        List<JSONObject> items = readAll();
        boolean updated = false;
        for (int i = 0; i < items.size(); i++)
        {
            if (item.getString("sessionId").equals(items.get(i).getString("sessionId")))
            {
                items.set(i, merge(items.get(i), item));
                updated = true;
                break;
            }
        }
        if (!updated)
        {
            items.add(item);
        }
        writeAll(items);
    }

    private JSONObject merge(JSONObject oldItem, JSONObject newItem)
    {
        JSONObject merged = new JSONObject(oldItem);
        for (String key : newItem.keySet())
        {
            Object value = newItem.get(key);
            if (value != null)
            {
                merged.put(key, value);
            }
        }
        return merged;
    }

    private JSONObject findBySessionId(String sessionId)
    {
        List<JSONObject> items = readAll();
        for (JSONObject item : items)
        {
            if (sessionId.equals(item.getString("sessionId")))
            {
                return item;
            }
        }
        return null;
    }

    private List<JSONObject> readAll()
    {
        if (!Files.exists(historyLog))
        {
            return new ArrayList<JSONObject>();
        }
        try
        {
            List<String> lines = Files.readAllLines(historyLog, StandardCharsets.UTF_8);
            List<JSONObject> items = new ArrayList<JSONObject>();
            for (String line : lines)
            {
                if (line != null && !line.trim().isEmpty())
                {
                    items.add(JSON.parseObject(line));
                }
            }
            return items;
        }
        catch (IOException ignored)
        {
            return new ArrayList<JSONObject>();
        }
    }

    private void writeAll(List<JSONObject> items)
    {
        try
        {
            Files.createDirectories(historyLog.getParent());
            List<String> lines = new ArrayList<String>();
            for (JSONObject item : items)
            {
                lines.add(item.toJSONString());
            }
            Files.write(historyLog, lines, StandardCharsets.UTF_8, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        }
        catch (IOException ignored)
        {
            // Ignore history persistence errors.
        }
    }

    private String resolveExt(String contentType)
    {
        if (contentType == null)
        {
            return ".jpg";
        }
        if (contentType.contains("png"))
        {
            return ".png";
        }
        if (contentType.contains("webp"))
        {
            return ".webp";
        }
        if (contentType.contains("mpeg") || contentType.contains("mp3"))
        {
            return ".mp3";
        }
        if (contentType.contains("wav"))
        {
            return ".wav";
        }
        if (contentType.contains("aac"))
        {
            return ".aac";
        }
        return ".jpg";
    }

    private String resolveContentType(String imagePath)
    {
        String lower = imagePath == null ? "" : imagePath.toLowerCase();
        if (lower.endsWith(".png"))
        {
            return "image/png";
        }
        if (lower.endsWith(".webp"))
        {
            return "image/webp";
        }
        return "image/jpeg";
    }

    public static class ImagePayload
    {
        private final byte[] bytes;
        private final String contentType;

        public ImagePayload(byte[] bytes, String contentType)
        {
            this.bytes = bytes;
            this.contentType = contentType;
        }

        public byte[] getBytes()
        {
            return bytes;
        }

        public String getContentType()
        {
            return contentType;
        }
    }
}
