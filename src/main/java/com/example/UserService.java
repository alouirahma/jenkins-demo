package com.example;

import java.util.HashMap;
import java.util.Map;

public class UserService {
    private final Map<Integer, String> users = new HashMap<>();
    
    public UserService() {
        users.put(1, "Alice");
        users.put(2, "Bob");
        users.put(3, "Charlie");
        users.put(4, "Diana");
        users.put(5, "Eve");
    }
    
    public String getUserName(int id) {
        return users.getOrDefault(id, "Utilisateur inconnu");
    }
    
    public int getUserCount() {
        return users.size();
    }
    
    public void addUser(int id, String name) {
        users.put(id, name);
    }
}
