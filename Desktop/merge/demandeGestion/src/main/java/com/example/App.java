package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("🚀 Application DevMedic - " + System.getProperty("user.name"));
        Calculator calc = new Calculator();
        System.out.println("10 + 20 = " + calc.add(10, 20));
        System.out.println("5 * 6 = " + calc.multiply(5, 6));
    }
}
