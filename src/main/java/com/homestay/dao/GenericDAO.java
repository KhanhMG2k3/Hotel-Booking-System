package com.homestay.dao;

import java.util.List;
import java.util.Optional;

/**
 * GenericDAO - Generic interface demonstrating OOP Abstraction and Polymorphism.
 * @param <T> Entity Type
 * @param <ID> Primary Key Type
 */
public interface GenericDAO<T, ID> {

    Optional<T> findById(ID id);

    List<T> findAll();

    boolean insert(T entity);

    boolean update(T entity);

    boolean delete(ID id);
}
