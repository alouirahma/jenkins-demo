package com.example;

import java.util.HashMap;
import java.util.Map;

public class UserService {
    private final Map<Integer, String> users = new HashMap<>();
    
    public UserService() {
        users.put(1, "Alice");
        users.put(2, "Bob");
        users.put(3, "Charlie");
    }
    
    public String getUserName(int id) {
        return users.getOrDefault(id, "Inconnu");
    }
}
