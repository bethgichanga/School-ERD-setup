# 🏫 School ERD Setup

A relational database schema for managing a school's core entities — students, teachers, support staff, classes, subjects, grades, and attendance.

---

## 📌 Project Overview

This project defines a normalized SQL schema for a school management system. It covers:

- Student registration and class enrollment
- Teacher and support staff records
- Subject assignments per class and teacher
- Academic grades per term
- Daily attendance tracking
- Guardian/parent contact information

---

## 🗂️ Folder Structure

```
School-ERD-setup/
│
├── README.md
├── erd/
│   ├── school_erd.png          # ERD diagram image
│   └── school_erd.sql          # Full SQL schema (CREATE TABLE statements)
├── docs/
│   ├── entities.md             # Entity descriptions
│   └── relationships.md        # Relationship explanations
└── queries/
    └── sample_queries.sql      # Practice/example SQL queries
```

---

## 🧩 Entities

| Entity | Description |
|---|---|
| `departments` | Academic and administrative departments |
| `teachers` | Teaching staff linked to departments |
| `support_staff` | Non-teaching staff (librarians, IT, counselors, etc.) |
| `subjects` | Courses offered, linked to departments |
| `classes` | Grade/section groupings with a homeroom teacher |
| `guardians` | Parent/guardian contact records |
| `students` | Core student records linked to a class and guardian |
| `enrollments` | Student–class relationship per academic year |
| `assignments` | Teacher–subject–class teaching allocations |
| `grades` | Student scores per subject per term |
| `attendance` | Daily student attendance records |

---

## 🔗 Key Relationships

```
departments   ──< teachers          (one department has many teachers)
departments   ──< subjects           (one department owns many subjects)
teachers      ──< classes            (one teacher is homeroom for many classes)
classes       ──< students           (one class has many students)
guardians     ──< students           (one guardian linked to many students)
students      ──< enrollments        (student enrolled in class per year)
teachers      ──< assignments        (teacher assigned to subject + class)
students      ──< grades             (student graded per subject per term)
students      ──< attendance         (student attendance per day)
```

---

## 🛠️ Tech Stack

- **Database**: PostgreSQL
- **Schema design**: Normalized to 3NF
- **Tools**: VS Code, pgAdmin / psql, Git + GitHub

---

## 🚀 Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/bethgichanga/School-ERD-setup.git
   cd School-ERD-setup
   ```

2. Run the schema in PostgreSQL:
   ```bash
   psql -U postgres -d your_database -f erd/school_erd.sql
   ```

3. Explore with sample queries in `queries/sample_queries.sql`

---

## 👩‍💻 Author

**Beth Gichanga**  
Data Engineer | Nairobi, Kenya  
[GitHub](https://github.com/bethgichanga)

---

## 📄 License

MIT License
