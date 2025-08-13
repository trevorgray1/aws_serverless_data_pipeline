-- PostgreSQL table creation for storing processed data
CREATE TABLE processed_data (
    id SERIAL PRIMARY KEY,
    data_key VARCHAR(255) NOT NULL,
    processed_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data JSONB NOT NULL
);
