package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AppTest {
    
    @Test
    void testAdd() {
        Calculator calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
        assertEquals(0, calc.add(-1, 1));
    }
    
    @Test
    void testSubtract() {
        Calculator calc = new Calculator();
        assertEquals(2, calc.subtract(5, 3));
        assertEquals(-2, calc.subtract(3, 5));
    }
    
    @Test
    void testMultiply() {
        Calculator calc = new Calculator();
        assertEquals(6, calc.multiply(2, 3));
        assertEquals(0, calc.multiply(5, 0));
    }
    
    @Test
    void testDivide() {
        Calculator calc = new Calculator();
        assertEquals(2.0, calc.divide(6, 3));
        assertEquals(2.5, calc.divide(5, 2));
    }
    
    @Test
    void testUserService() {
        UserService service = new UserService();
        assertEquals("Alice", service.getUserName(1));
        assertEquals("Utilisateur inconnu", service.getUserName(999));
    }
}
