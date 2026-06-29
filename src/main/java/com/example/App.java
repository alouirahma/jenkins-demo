package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("🚀 Application DevMedic v3.0");
        Calculator calc = new Calculator();
        UserService userService = new UserService();
        
        System.out.println("10 + 20 = " + calc.add(10, 20));
        System.out.println("5 * 6 = " + calc.multiply(5, 6));
        System.out.println("4^2 = " + calc.square(4));
        System.out.println("Utilisateur 1 : " + userService.getUserName(1));
        System.out.println("Utilisateur 5 : " + userService.getUserName(5));
        System.out.println("Total utilisateurs : " + userService.getUserCount());
    }
}

        System.out.println("5^3 = " + calc.cube(5));
        System.out.println("2^10 = " + calc.power(2, 10));
