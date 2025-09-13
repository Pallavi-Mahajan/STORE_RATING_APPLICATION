-- RateMyStore Database Schema
-- Create database
CREATE DATABASE IF NOT EXISTS ratemystore_db;
USE ratemystore_db;

-- Users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'user', 'store_owner') DEFAULT 'user',
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- Stores table
CREATE TABLE stores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0.0,
    total_ratings INT DEFAULT 0,
    owner_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_name (name),
    INDEX idx_rating (rating),
    INDEX idx_owner (owner_id)
);

-- Ratings table
CREATE TABLE ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    store_id INT NOT NULL,
    rating_value INT NOT NULL CHECK (rating_value >= 1 AND rating_value <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_store (user_id, store_id),
    INDEX idx_user (user_id),
    INDEX idx_store (store_id),
    INDEX idx_rating (rating_value)
);

-- Insert default admin user (CORRECTED PASSWORD HASH)
INSERT INTO users (name, email, password, role, address) VALUES 
('System Admin', 'admin@ratemystore.com', '$2a$10$CwTycUXWue0Thq9StjUM0uBUcV/Ka4bNx7b5i/P2uZQbIgL9qb.dO', 'admin', 'System Address');

-- Trigger to update store rating when a new rating is added
DELIMITER //
CREATE TRIGGER update_store_rating_after_insert
AFTER INSERT ON ratings
FOR EACH ROW
BEGIN
    UPDATE stores 
    SET rating = (
        SELECT AVG(rating_value) 
        FROM ratings 
        WHERE store_id = NEW.store_id
    ),
    total_ratings = (
        SELECT COUNT(*) 
        FROM ratings 
        WHERE store_id = NEW.store_id
    )
    WHERE id = NEW.store_id;
END//

-- Trigger to update store rating when a rating is updated
CREATE TRIGGER update_store_rating_after_update
AFTER UPDATE ON ratings
FOR EACH ROW
BEGIN
    UPDATE stores 
    SET rating = (
        SELECT AVG(rating_value) 
        FROM ratings 
        WHERE store_id = NEW.store_id
    ),
    total_ratings = (
        SELECT COUNT(*) 
        FROM ratings 
        WHERE store_id = NEW.store_id
    )
    WHERE id = NEW.store_id;
END//

-- Trigger to update store rating when a rating is deleted
CREATE TRIGGER update_store_rating_after_delete
AFTER DELETE ON ratings
FOR EACH ROW
BEGIN
    UPDATE stores 
    SET rating = COALESCE((
        SELECT AVG(rating_value) 
        FROM ratings 
        WHERE store_id = OLD.store_id
    ), 0.0),
    total_ratings = (
        SELECT COUNT(*) 
        FROM ratings 
        WHERE store_id = OLD.store_id
    )
    WHERE id = OLD.store_id;
END//
DELIMITER ;