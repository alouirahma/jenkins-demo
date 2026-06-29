package com.example;

public class Calculator {
    public int add(int a, int b) { return a + b; }
    public int subtract(int a, int b) { return a - b; }
    public int multiply(int a, int b) { return a * b; }
    public int divide(int a, int b) { 
        if (b == 0) throw new IllegalArgumentException("Division par zéro");
        return a / b; 
    }
}

    public int square(int x) { return x * x; }

    public int cube(int x) { return x * x * x; }

    public int cube(int x) { return x * x * x; }

    public double power(double base, int exp) { return Math.pow(base, exp); }

    public int modulo(int a, int b) { return a % b; }

    public int factorial(int n) { if (n <= 1) return 1; return n * factorial(n - 1); }
