# Project-IV1351

The project for course IV1351 made by Project Group 96

The members of the group:

- Lukas Andersson
- John Elofsson
- Zakarias Fagerstedt

## Project file structure

To create the database you must use PostgreSQL. To fully build the database and create all tables, functions, views and populate it with data sample data, navigate to the scripts directory and run the script [build_database.sql](/scripts/build_database.sql).

To refresh the materialized views in the database, run the script [refresh_views.sql](/scripts/refresh_views.sql).

The individual scripts for each step of the build process are:

The SQL script for building the database, [create_database.sql](/scripts/create_database.sql), and the script for populating the database with data, [create_data.sql](/scripts/create_data.sql), are located in the scripts directory. To create relevant views for the application, run the script [create_views.sql](/scripts/create_views.sql).

The script for populating the database was made by generating data using a online data generation tool.

## Logical model

![Logical model](./Logical_Model.svg)
