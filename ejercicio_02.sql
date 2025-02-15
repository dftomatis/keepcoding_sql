-- Crear BD keepcoding y corerr el siguiente script dentro de la misma

-- Crear la tabla documents_types
create table documents_types (
    document_type_id serial primary key,
    description varchar(20) not null,
    abbreviated_name varchar(10)
);

-- crear la tabla users
create table users (
    user_id serial primary key,
    user_name varchar(50) not null,
    email varchar(255) not null unique,
    password_hash varchar(255) not null
);

-- crear la tabla status
create table status (
    status_id serial primary key,
    description varchar(20) not null,
    abbreviated_name varchar(10)
);

-- crear la tabla teachers
create table teachers (
    teacher_id serial primary key,
    teacher_name varchar(50) not null,
    surname varchar(50) not null,
    birthdate date not null,
    document_type_id int not null references documents_types(document_type_id) on delete restrict,
    document_number varchar(20) not null unique,
    user_id int references users(user_id) on delete set null,
    phone_number varchar(20),
    address varchar(100),
    teacher_state varchar(50),
    country varchar(50),
    tax_id varchar(20)
);

-- crear la tabla bank_accounts
create table bank_accounts (
    account_id serial primary key,
    teacher_id int not null references teachers(teacher_id) on delete cascade,
    account_number varchar(50) not null unique,
    bank_name varchar(100) not null,
    currency_code varchar(3) not null
);

-- crear la tabla students
create table students (
    enrollment_id serial primary key,
    student_name varchar(50) not null,
    surname varchar(50) not null,
    birthdate date not null,
    phone_number varchar(20),
    user_id int references users(user_id) on delete set null,
    address varchar(100),
    student_state varchar(50),
    country varchar(50),
    document_number varchar(20) not null unique,
    document_type_id int not null references documents_types(document_type_id) on delete restrict
);

-- crear la tabla courses
create table courses (
    course_id serial primary key,
    course_name varchar(100) not null,
    description varchar(500),
    duration_hours int,
    price decimal(10,2) not null
);

-- crear la tabla modules
create table modules (
    module_id serial primary key,
    module_name varchar(50) not null,
    description varchar(500),
    duration_hours int,
    price decimal(10,2)
);

-- crear la tabla modules_courses
create table modules_courses (
    course_id int not null references courses(course_id) on delete cascade,
    module_id int not null references modules(module_id) on delete cascade,
    teacher_id int references teachers(teacher_id) on delete set null,
    description varchar(500),
    primary key (course_id, module_id)
);

--- crear la tabla classes
create table classes (
    class_id serial primary key,
    class_name varchar(100) not null,
    description varchar(500),
    duration_minutes int,
    video_url varchar(255),
    teacher_id int references teachers(teacher_id) on delete set null,
    course_id int not null,
    module_id int not null,
    foreign key (course_id, module_id) references modules_courses(course_id, module_id) on delete cascade
);

-- crear la tabla teachers_courses
create table teachers_courses (
    course_id int not null references courses(course_id) on delete cascade,
    teacher_id int not null references teachers(teacher_id) on delete cascade,
    description varchar(500),
    primary key (course_id, teacher_id)
);

-- crear la tabla progress_modules
create table progress_modules (
    course_id int not null,
    module_id int not null,
    student_id int not null,
    complete boolean not null default false,
    certificate_url varchar(255),
    primary key (course_id, module_id, student_id),
    foreign key (course_id, module_id) references modules_courses(course_id, module_id) on delete cascade,
    foreign key (student_id) references students(enrollment_id) on delete cascade
);

-- crear la tabla progress
create table progress (
    class_id int not null references classes(class_id) on delete cascade,
    student_id int not null references students(enrollment_id) on delete cascade,
    watched boolean default false,
    watched_at timestamp,
    watched_count int default 1,
    primary key (class_id, student_id)
);

-- crear la tabla formations
create table formations (
    course_id int not null references courses(course_id) on delete cascade,
    student_id int not null references students(enrollment_id) on delete cascade,
    enrollment_date date not null default current_date,
    completion_date date,
    complete boolean not null default false,
    certificate_url varchar(255),
    status_id int not null references status(status_id) on delete restrict,
    primary key (course_id, student_id)
);
