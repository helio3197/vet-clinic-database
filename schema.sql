/* Database schema to keep the structure of entire database. */

CREATE TABLE animals (
id int GENERATED ALWAYS AS IDENTITY,
name varchar(100),
date_of_birth date,
escape_attempts int,
neutered boolean,
weight_kg decimal,
PRIMARY KEY (id)
);

ALTER TABLE animals ADD species varchar(100);

CREATE TABLE owners (
id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
full_name varchar(100),
age int
);

CREATE TABLE species (
id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
name varchar(100)
);

ALTER TABLE animals DROP species;
ALTER TABLE animals ADD species_id int REFERENCES species(id);
ALTER TABLE animals ADD owner_id int REFERENCES owners(id);
