/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.homestay.context;

import org.mindrot.jbcrypt.BCrypt;

public class HashSeedPasswords {

    public static void main(String[] args) {
        System.out.println("admin123 -> " + BCrypt.hashpw("admin123", BCrypt.gensalt()));
        System.out.println("123456   -> " + BCrypt.hashpw("123456", BCrypt.gensalt()));
    }
}
