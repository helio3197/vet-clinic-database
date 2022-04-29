/*Queries that provide answers to the questions from all projects.*/

SELECT * FROM animals WHERE name LIKE '%mon';

SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';

SELECT name FROM animals WHERE neutered IS TRUE AND escape_attempts < 3;

SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');

SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;

SELECT * FROM animals WHERE neutered IS TRUE;

SELECT * FROM animals WHERE NOT name = 'Gabumon';

SELECT * FROM animals WHERE weight_kg >= 10.4 AND weight_kg <= 17.3;

BEGIN;
UPDATE animals SET species = 'unspecified';
SELECT * FROM animals;
ROLLBACK;
SELECT * FROM animals;

BEGIN;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;
COMMIT;
SELECT * FROM animals;

BEGIN;
DELETE FROM animals;
ROLLBACK;
SELECT * FROM animals;

BEGIN;
DELETE FROM animals WHERE date_of_birth > 'Jan 1, 2022';
SAVEPOINT savepoint1;
UPDATE animals SET weight_kg = weight_kg * -1;
ROLLBACK TO savepoint1;
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 0;
COMMIT;

/* How many animals are there? */
SELECT COUNT(*) FROM animals;

/* How many animals have never tried to escape? */
SELECT escape_attempts, COUNT(*) FROM animals
GROUP BY escape_attempts HAVING escape_attempts = 0;

/* What is the average weight of animals? */
SELECT AVG(weight_kg) FROM animals;

/*Who escapes the most, neutered or not neutered animals? */
SELECT neutered, COUNT(*) FROM animals GROUP BY neutered;

/* What is the minimum and maximum weight of each type of animal? */
SELECT species, MIN(weight_kg), MAX(weight_kg) FROM animals
GROUP BY species;

/* What is the average number of escape attempts per animal type of those born between 1990 and 2000? */
SELECT species, AVG(escape_attempts) FROM animals WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'
GROUP BY species;

/* What animals belong to Melody Pond? */
SELECT name, full_name AS owner FROM animals JOIN owners ON animals.owner_id = owners.id
WHERE full_name = 'Melody Pond';

/* List of all animals that are pokemon (their type is Pokemon). */
SELECT animals.name, species.name AS species FROM animals JOIN species ON species_id = species.id
WHERE species.name = 'Pokemon';

/* List all owners and their animals, remember to include those that don't own any animal. */
SELECT full_name, name FROM animals RIGHT JOIN owners ON owner_id = owners.id;

/* How many animals are there per species? */
SELECT species.name AS species, COUNT(species.name) FROM animals JOIN species ON species_id = species.id
GROUP BY species.name;

/* List all Digimon owned by Jennifer Orwell. */
SELECT animals.name, full_name AS owner, species.name AS species FROM animals
JOIN owners ON owners.id = owner_id
JOIN species ON species.id = species_id
WHERE full_name = 'Jennifer Orwell' AND species.name = 'Digimon';

/* List all animals owned by Dean Winchester that haven't tried to escape. */
SELECT name, full_name AS owner, escape_attempts FROM animals JOIN owners ON owner_id = owners.id
WHERE full_name = 'Dean Winchester' AND escape_attempts = 0;

/* Who owns the most animals? */
SELECT full_name AS owner, COUNT(animals.name) FROM animals JOIN owners ON owner_id = owners.id
GROUP BY full_name HAVING COUNT(animals.name) = (SELECT MAX(sub_table.count) FROM (
  SELECT COUNT(animals.name) AS count FROM animals JOIN owners ON owner_id = owners.id
  GROUP BY full_name) sub_table
);

/* Who was the last animal seen by William Tatcher? */
SELECT animals.name, vets.name AS vet_name, visit_date FROM visits
JOIN animals ON animal_id = animals.id JOIN vets ON vet_id = vets.id
WHERE vet_id = (SELECT id FROM vets WHERE name = 'William Tatcher')
ORDER BY visit_date DESC LIMIT 1;

/* How many different animals did Stephanie Mendez see? */
SELECT V.name AS vet_name, (
  SELECT COUNT(*) FROM (
    SELECT vet_id, animal_id FROM visits GROUP BY vet_id, animal_id
  ) sub_table GROUP BY vet_id HAVING vet_id = V.id) AS animal_count
FROM visits JOIN animals ON animal_id = animals.id JOIN vets V ON vet_id = V.id
GROUP BY vet_name, V.id HAVING V.name = 'Stephanie Mendez';

/* Alternate solution */
SELECT V.name AS vet_name, Q.animal_count
FROM visits Vi
JOIN animals ON Vi.animal_id = animals.id
JOIN vets V ON Vi.vet_id = V.id
LEFT JOIN (
  SELECT COUNT(*) AS animal_count, vet_id FROM (
    SELECT vet_id, animal_id FROM visits GROUP BY vet_id, animal_id
  ) sub_table GROUP BY vet_id
) Q ON Q.vet_id = V.id
GROUP BY vet_name, Q.animal_count HAVING V.name = 'Stephanie Mendez';

/* List all vets and their specialties, including vets with no specialties. */
SELECT vets.name, species.name AS species
FROM vets
LEFT JOIN specializations ON vets.id = specializations.vet_id
LEFT JOIN species ON species.id = specializations.species_id

/* List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020. */
SELECT animals.name, vets.name AS vet_name, visit_date
FROM visits JOIN animals ON animals.id = animal_id JOIN vets ON vets.id = vet_id
WHERE vets.name = 'Stephanie Mendez' AND visit_date BETWEEN '2020-04-01' AND '2020-08-30';

/* What animal has the most visits to vets? */
SELECT animals.name, COUNT(vet_id)
FROM visits JOIN animals ON animals.id = animal_id
GROUP BY animals.name ORDER BY COUNT DESC LIMIT 1;

/* Who was Maisy Smith's first visit? */
SELECT animals.name, vets.name AS vet_name, visit_date
FROM visits JOIN animals ON animals.id = animal_id JOIN vets ON vets.id = vet_id
WHERE vets.name = 'Maisy Smith' ORDER BY visit_date LIMIT 1;

/* Details for most recent visit: animal information, vet information, and date of visit. */
SELECT animals.*, vets.*, visit_date
FROM visits JOIN animals ON animals.id = animal_id JOIN vets ON vets.id = vet_id
ORDER BY visit_date DESC LIMIT 1;

/* How many visits were with a vet that did not specialize in that animal's species? */
SELECT vets.name AS vet_name, COUNT(*)
FROM visits JOIN vets ON vets.id = vet_id LEFT JOIN specializations ON specializations.vet_id = vets.id
WHERE specializations.vet_id IS NULL
GROUP BY vet_name;

/* What specialty should Maisy Smith consider getting? Look for the species she gets the most. */
SELECT species.name AS species, COUNT(*)
FROM visits
JOIN animals ON animals.id = visits.animal_id
JOIN species ON species.id = animals.species_id
WHERE visits.vet_id = (SELECT id FROM vets WHERE name = 'Maisy Smith')
GROUP BY species.name ORDER BY COUNT DESC LIMIT 1;
