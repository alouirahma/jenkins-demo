package com.example;

import java.util.*;
import java.time.*;
import java.util.stream.*;

public class LargeDataGenerator {
    
    private static final Random random = new Random();
    private static final List<String> NAMES = Arrays.asList(
        "Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace", "Henry", 
        "Ivy", "Jack", "Karen", "Leo", "Mia", "Noah", "Olivia", "Peter",
        "Quinn", "Rose", "Sam", "Tina", "Uma", "Victor", "Wendy", "Xavier",
        "Yara", "Zoe", "Adam", "Bella", "Cody", "Daisy"
    );
    
    public static List<String> generateNames(int count) {
        List<String> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            result.add(NAMES.get(random.nextInt(NAMES.size())) + "_" + i);
        }
        return result;
    }
    
    public static List<Integer> generateIntegers(int count, int min, int max) {
        List<Integer> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            result.add(random.nextInt(max - min + 1) + min);
        }
        return result;
    }
    
    public static List<Double> generateDoubles(int count, double min, double max) {
        List<Double> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            result.add(min + (max - min) * random.nextDouble());
        }
        return result;
    }
    
    public static List<String> generateWords(int count, int minLength, int maxLength) {
        String chars = "abcdefghijklmnopqrstuvwxyz";
        List<String> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            int length = random.nextInt(maxLength - minLength + 1) + minLength;
            StringBuilder sb = new StringBuilder();
            for (int j = 0; j < length; j++) {
                sb.append(chars.charAt(random.nextInt(chars.length())));
            }
            result.add(sb.toString());
        }
        return result;
    }
    
    public static List<String> generateSentences(int count, int minWords, int maxWords) {
        List<String> words = generateWords(100, 3, 8);
        List<String> result = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            int wordCount = random.nextInt(maxWords - minWords + 1) + minWords;
            StringBuilder sb = new StringBuilder();
            for (int j = 0; j < wordCount; j++) {
                sb.append(words.get(random.nextInt(words.size()))).append(" ");
            }
            result.add(sb.toString().trim());
        }
        return result;
    }
    
    public static Map<String, Integer> generateScoreMap(String[] keys, int min, int max) {
        Map<String, Integer> map = new HashMap<>();
        for (String key : keys) {
            map.put(key, random.nextInt(max - min + 1) + min);
        }
        return map;
    }
    
    public static <T> List<T> shuffleList(List<T> list) {
        List<T> result = new ArrayList<>(list);
        Collections.shuffle(result);
        return result;
    }
    
    public static <T> Set<T> generateSet(List<T> source, int size) {
        Set<T> result = new HashSet<>();
        while (result.size() < Math.min(size, source.size())) {
            result.add(source.get(random.nextInt(source.size())));
        }
        return result;
    }
    
    public static void main(String[] args) {
        System.out.println("=== GÉNÉRATION DE DONNÉES ===");
        System.out.println("Noms générés: " + generateNames(50).size());
        System.out.println("Entiers générés: " + generateIntegers(100, 1, 1000).size());
        System.out.println("Doubles générés: " + generateDoubles(50, 0, 1).size());
        System.out.println("Mots générés: " + generateWords(100, 3, 10).size());
        System.out.println("Phrases générées: " + generateSentences(20, 5, 15).size());
        System.out.println("Scores générés: " + generateScoreMap(
            new String[]{"Math", "Physics", "Chemistry", "Biology", "History", "Geography"}, 0, 100).size());
        System.out.println("=== FIN DE LA GÉNÉRATION ===");
    }
}
