CREATE TABLE IF NOT EXISTS instrument_types (
    instrument_type_id SERIAL,
    name varchar(10),
    PRIMARY KEY(instrument_type_id)
);

CREATE TABLE IF NOT EXISTS instructor_instruments (
    instructor_instruments_id SERIAL,
    instructor_id integer,
    instrument_id integer,
    FOREIGN KEY(instructor_id) REFERENCES instructors(instructor_id),
    FOREIGN KEY(instrument_id) REFERENCES instrument_types(instrument_type_id),
    PRIMARY KEY(instructor_instruments_id)
);

CREATE TABLE IF NOT EXISTS people (
    personal_number SERIAL,
    name varchar(15),
    address, varchar(15),
    contact_details, varchar(30),
    PRIMARY KEY (personal_number)
);

CREATE TABLE IF NOT EXISTS students (
    student_id SERIAL,
    contact_person, varchar(15),
    sibling_group integer NOT NULL,
    PRIMARY KEY(student_id)
) INHERITS (people);

CREATE TABLE IF NOT EXISTS instructors (
    instructor_id SERIAL,
    instruments integer,
    enseble boolean NOT NULL,
    individual_start_time time,
    individual_stop_time time,
    FOREIGN KEY(instruments) REFERENCES instructor_instruments(instructor_instruments_id),
    PRIMARY KEY(instructor_id)
);