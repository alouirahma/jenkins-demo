package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("🚀 Application DevMedic Demo");
        Calculator calc = new Calculator();
        UserService userService = new UserService();
        
        System.out.println("10 + 20 = " + calc.add(10, 20));
        System.out.println("5 * 6 = " + calc.multiply(5, 6));
        System.out.println("4^2 = " + calc.square(4));
        System.out.println("Utilisateur 1 : " + userService.getUserName(1));
    }
}
