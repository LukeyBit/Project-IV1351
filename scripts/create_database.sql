CREATE DATABASE soundgood;

\c soundgood

CREATE TYPE LESSON_TYPE AS ENUM ('group', 'individual', 'ensemble');
CREATE TYPE LESSON_LEVEL AS ENUM ('beginner', 'intermediate', 'advanced');

CREATE TABLE IF NOT EXISTS people (
    personal_number BIGINT,
    name varchar(64) NOT NULL,
    address varchar(64) NOT NULL,
    contact_details varchar(64) NOT NULL,
    PRIMARY KEY (personal_number)
);

CREATE TABLE IF NOT EXISTS students (
    student_id SERIAL,
    contact_person varchar(64),
    sibling_group integer NOT NULL,
    PRIMARY KEY(student_id)
) INHERITS (people);

CREATE TABLE IF NOT EXISTS instructors (
    instructor_id SERIAL,
    ensemble boolean NOT NULL,
    individual_start_time time,
    individual_stop_time time,
    PRIMARY KEY(instructor_id)
) INHERITS (people);

CREATE TABLE IF NOT EXISTS instrument_types (
    instrument_type_id SERIAL,
    name varchar(32) NOT NULL,
    PRIMARY KEY(instrument_type_id)
);

CREATE TABLE IF NOT EXISTS instructor_instruments (
    instructor_instruments_id SERIAL,
    instructor integer NOT NULL,
    instrument_type integer NOT NULL,
    FOREIGN KEY(instructor) REFERENCES instructors(instructor_id) ON DELETE CASCADE,
    FOREIGN KEY(instrument_type) REFERENCES instrument_types(instrument_type_id) ON DELETE CASCADE,
    PRIMARY KEY(instructor_instruments_id)
);

CREATE TABLE IF NOT EXISTS instruments (
    instrument_id SERIAL,
    brand varchar(10) NOT NULL,
    model varchar(15) NOT NULL,
    rental_cost integer NOT NULL,
    PRIMARY KEY(instrument_id)
);

CREATE TABLE IF NOT EXISTS rentals (
    rental_id SERIAL,
    student integer NOT NULL,
    instrument integer NOT NULL,
    start_date timestamp NOT NULL,
    end_date timestamp NOT NULL,
    FOREIGN KEY(student) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY(instrument) REFERENCES instruments(instrument_id) ON DELETE CASCADE,
    PRIMARY KEY(rental_id)
);

CREATE TABLE IF NOT EXISTS lessons (
    lesson_id SERIAL,
    lesson_type LESSON_TYPE NOT NULL,
    instructor integer NOT NULL,
    lesson_start timestamp NOT NULL,
    lesson_end timestamp NOT NULL,
    FOREIGN KEY(instructor) REFERENCES instructors(instructor_id) ON DELETE CASCADE,
    PRIMARY KEY(lesson_id)
);

CREATE TABLE IF NOT EXISTS individual_lessons (
    individual_lesson_id SERIAL,
    instrument_type integer NOT NULL,
    lesson_level LESSON_LEVEL NOT NULL,
    FOREIGN KEY(instrument_type) REFERENCES instrument_types(instrument_type_id) ON DELETE CASCADE,
    PRIMARY KEY(individual_lesson_id)
) INHERITS (lessons);

CREATE TABLE IF NOT EXISTS group_lessons (
    group_lesson_id SERIAL,
    instrument_type integer NOT NULL,
    lesson_level LESSON_LEVEL NOT NULL,
    minimum_students integer NOT NULL,
    maximum_students integer NOT NULL,
    FOREIGN KEY(instrument_type) REFERENCES instrument_types(instrument_type_id) ON DELETE CASCADE,
    PRIMARY KEY(group_lesson_id)
) INHERITS (lessons);

CREATE TABLE IF NOT EXISTS ensemble_lessons (
    ensemble_lesson_id SERIAL,
    genre varchar(15) NOT NULL,
    minimum_students integer NOT NULL,
    maximum_students integer NOT NULL,
    PRIMARY KEY(ensemble_lesson_id)
) INHERITS (lessons);

CREATE TABLE IF NOT EXISTS attendances (
    attendance_id SERIAL,
    lesson integer NOT NULL,
    student integer NOT NULL,
    FOREIGN KEY(lesson) REFERENCES lessons(lesson_id) ON DELETE CASCADE,
    FOREIGN KEY(student) REFERENCES students(student_id) ON DELETE CASCADE,
    PRIMARY KEY(attendance_id)
);

CREATE TABLE IF NOT EXISTS prices (
    price_id SERIAL,
    lesson_type LESSON_TYPE NOT NULL,
    lesson_level LESSON_LEVEL,
    price integer NOT NULL,
    PRIMARY KEY(price_id)
);

-- Propagates insertions to the lessons table from its child tables
CREATE OR REPLACE FUNCTION propagate_to_lessons()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO lessons (lesson_id, lesson_type, instructor, lesson_start, lesson_end)
  VALUES (NEW.lesson_id, NEW.lesson_type, NEW.instructor, NEW.lesson_start, NEW.lesson_end);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER propagate_individual_lessons
AFTER INSERT ON individual_lessons
FOR EACH ROW EXECUTE FUNCTION propagate_to_lessons();

CREATE TRIGGER propagate_group_lessons
AFTER INSERT ON group_lessons
FOR EACH ROW EXECUTE FUNCTION propagate_to_lessons();

CREATE TRIGGER propagate_ensemble_lessons
AFTER INSERT ON ensemble_lessons
FOR EACH ROW EXECUTE FUNCTION propagate_to_lessons();

-- Propagates updates to the lessons table from child tables
CREATE OR REPLACE FUNCTION update_lessons_on_child_update()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE lessons
    SET
        lesson_type = NEW.lesson_type,
        instructor = NEW.instructor,
        lesson_start = NEW.lesson_start,
        lesson_end = NEW.lesson_end
    WHERE lesson_id = NEW.lesson_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_individual_lessons
AFTER UPDATE ON individual_lessons
FOR EACH ROW
EXECUTE FUNCTION update_lessons_on_child_update();

CREATE TRIGGER update_group_lessons
AFTER UPDATE ON group_lessons
FOR EACH ROW
EXECUTE FUNCTION update_lessons_on_child_update();

CREATE TRIGGER update_ensemble_lessons
AFTER UPDATE ON ensemble_lessons
FOR EACH ROW
EXECUTE FUNCTION update_lessons_on_child_update();

-- Propagates deletions to the lessons table from the child tables
CREATE OR REPLACE FUNCTION delete_from_lessons_on_child_delete()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM lessons
    WHERE lesson_id = OLD.lesson_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_individual_lessons
AFTER DELETE ON individual_lessons
FOR EACH ROW
EXECUTE FUNCTION delete_from_lessons_on_child_delete();

CREATE TRIGGER delete_group_lessons
AFTER DELETE ON group_lessons
FOR EACH ROW
EXECUTE FUNCTION delete_from_lessons_on_child_delete();

CREATE TRIGGER delete_ensemble_lessons
AFTER DELETE ON ensemble_lessons
FOR EACH ROW
EXECUTE FUNCTION delete_from_lessons_on_child_delete();

-- Cascades deletions from the lessons table to its child tables
CREATE OR REPLACE FUNCTION cascade_delete_to_child_tables()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM individual_lessons WHERE lesson_id = OLD.lesson_id;
    DELETE FROM group_lessons WHERE lesson_id = OLD.lesson_id;
    DELETE FROM ensemble_lessons WHERE lesson_id = OLD.lesson_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cascade_delete_lessons
BEFORE DELETE ON lessons
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_to_child_tables();
