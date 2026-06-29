package com.example;

import java.util.*;
import java.time.*;

public class DataGenerator {
    private static final Random random = new Random();
    
    public static List<String> generateNames(int count) {
        String[] names = {"Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace", "Henry", "Ivy", "Jack"};
        List<String> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            result.add(names[random.nextInt(names.length)] + "_" + i);
        }
        return result;
    }
    
    public static List<Integer> generateNumbers(int count, int min, int max) {
        List<Integer> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            result.add(random.nextInt(max - min + 1) + min);
        }
        return result;
    }
    
    public static Map<String, Integer> generateScoreMap(String[] keys) {
        Map<String, Integer> map = new HashMap<>();
        for (String key : keys) {
            map.put(key, random.nextInt(100));
        }
        return map;
    }
    
    public static List<String> generateSentences(int count) {
        String[] words = {"Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", 
                         "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", 
                         "magna", "aliqua", "Ut", "enim", "ad", "minim", "veniam", "quis", "nostrud", 
                         "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", 
                         "commodo", "consequat", "Duis", "aute", "irure", "dolor", "in", "reprehenderit"};
        List<String> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            int wordCount = random.nextInt(10) + 5;
            StringBuilder sb = new StringBuilder();
            for (int j = 0; j < wordCount; j++) {
                sb.append(words[random.nextInt(words.length)]).append(" ");
            }
            result.add(sb.toString().trim());
        }
        return result;
    }
    
    public static void main(String[] args) {
        System.out.println("Génération de données...");
        List<String> names = generateNames(50);
        List<Integer> numbers = generateNumbers(100, 1, 1000);
        Map<String, Integer> scores = generateScoreMap(new String[]{"Math", "Physics", "Chemistry", "Biology"});
        
        System.out.println("Noms: " + names.size() + " générés");
        System.out.println("Nombres: " + numbers.size() + " générés");
        System.out.println("Scores: " + scores);
        System.out.println("Phrases: " + generateSentences(50).size() + " générées");
    }
}

    public static double generateDouble(double min, double max) { return min + (max - min) * random.nextDouble(); }
