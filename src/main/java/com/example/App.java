package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello DevMedic!");
        Calculator calc = new Calculator();
        System.out.println("10 + 20 = " + calc.add(10, 20));
        System.out.println("5 * 6 = " + calc.multiply(5, 6));
        System.out.println("100 - 45 = " + calc.subtract(100, 45));
    }
}
