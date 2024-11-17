use flutter_rust_bridge::frb;
use rusqlite::{params, Connection, Result};
use std::env;
use std::sync::{Arc, Mutex};
#[derive(Debug)]
pub struct Student {
    pub student_id: i32,
    pub name: String,
    pub major: String,
    pub grade: i32,
    pub class: String,
    pub email: String,
    pub phone_number: String,
}

#[derive(Debug)]
pub struct Course {
    pub course_id: i32,
    pub course_name: String,
    pub teacher_id: i32,
    pub classroom: String,
    pub time_slot: String,
    pub semester: String,
    pub credit: i32,
    pub capacity: i32,
}

#[derive(Debug)]
pub struct Enrollment {
    pub enrollment_id: i32,
    pub student_id: i32,
    pub course_id: i32,
    pub semester: String,
    pub status: String,
}

pub struct Database {
    conn: Arc<Mutex<Connection>>,
}

impl Database {
    pub fn new(db_path: &str) -> Result<Self> {
        // 获取当前工作目录
        let conn = Arc::new(Mutex::new(Connection::open(db_path)?));
        Self::initialize_tables(&conn)?;
        Ok(Database { conn })
    }

    fn initialize_tables(conn: &Arc<Mutex<Connection>>) -> Result<()> {
        let conn = conn.lock().unwrap();
        println!("Database path: {:?}", conn.path());
        // 创建 Student 表
        conn.execute(
            r"
            CREATE TABLE IF NOT EXISTS Student (
                student_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                major TEXT NOT NULL,
                grade INTEGER NOT NULL,
                class TEXT NOT NULL,
                email TEXT NOT NULL,
                phone_number TEXT NOT NULL
            )
            ",
            (),
        )?;

        // 插入示例学生数据
        if conn.query_row("SELECT COUNT(*) FROM Student", [], |row| {
            row.get::<_, i32>(0)
        })? == 0
        {
            conn.execute(
                r"
                INSERT INTO Student (name, major, grade, class, email, phone_number)
                VALUES 
                    ('阿尼亚', '计算机科学', 1, 'A班', 'aniya@example.com', '12345678901')
                ",
                (),
            )?;
        }

        // 创建 Course 表
        conn.execute(
            r"
            CREATE TABLE IF NOT EXISTS Course (
                course_id INTEGER PRIMARY KEY AUTOINCREMENT,
                course_name TEXT NOT NULL,
                teacher_id INTEGER NOT NULL,
                classroom TEXT NOT NULL,
                time_slot TEXT NOT NULL,
                semester TEXT NOT NULL,
                credit INTEGER NOT NULL,
                capacity INTEGER NOT NULL
            )
            ",
            (),
        )?;

        // 插入示例课程数据
        if conn.query_row("SELECT COUNT(*) FROM Course", [], |row| {
            row.get::<_, i32>(0)
        })? == 0
        {
            conn.execute(
                r"
                INSERT INTO Course (course_name, teacher_id, classroom, time_slot, semester, credit, capacity)
                VALUES 
                    ('数据库原理', 1, '101', '周一 10:00-12:00', '2023-2024秋季', 3, 30),
                    ('数据结构', 2, '102', '周二 14:00-16:00', '2023-2024秋季', 4, 25),
                    ('操作系统', 3, '103', '周三 10:00-12:00', '2023-2024秋季', 4, 30),
                    ('计算机网络', 4, '104', '周四 14:00-16:00', '2023-2024秋季', 3, 25),
                    ('算法设计与分析', 5, '105', '周五 10:00-12:00', '2023-2024秋季', 4, 30),
                    ('软件工程', 6, '106', '周一 14:00-16:00', '2023-2024秋季', 3, 25),
                    ('人工智能', 7, '107', '周二 10:00-12:00', '2023-2024秋季', 4, 30),
                    ('机器学习', 8, '108', '周三 14:00-16:00', '2023-2024秋季', 4, 25);
                ",
                (),
            )?;
        }

        // 创建 Enrollment 表
        conn.execute(
            r"
            CREATE TABLE IF NOT EXISTS Enrollment (
                enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
                student_id INTEGER NOT NULL,
                course_id INTEGER NOT NULL,
                semester TEXT NOT NULL,
                status TEXT NOT NULL,
                FOREIGN KEY (student_id) REFERENCES Student(student_id),
                FOREIGN KEY (course_id) REFERENCES Course(course_id)
            )
            ",
            (),
        )?;

        // 插入示例选课数据
        if conn.query_row("SELECT COUNT(*) FROM Enrollment", [], |row| {
            row.get::<_, i32>(0)
        })? == 0
        {
            conn.execute(
                r"
                INSERT INTO Enrollment (student_id, course_id, semester, status)
                VALUES 
                    (1, 1, '2023-2024秋季', '已选'),  -- 数据库原理
                    (1, 3, '2023-2024秋季', '已选'),  -- 操作系统
                    (1, 5, '2023-2024秋季', '已选');  -- 算法设计与分析
                ",
                (),
            )?;
        }

        Ok(())
    }

    pub fn enroll_student(&self, student_id: i32, course_id: i32, semester: &str) -> Result<()> {
        let conn = self.conn.lock().unwrap();
        conn.execute(
            "
            INSERT INTO Enrollment (student_id, course_id, semester, status)
            VALUES (?1, ?2, ?3, ?4)
            ",
            params![&student_id, &course_id, &semester, "已选"],
        )?;
        Ok(())
    }

    pub fn unenroll_student(&self, student_id: i32, course_id: i32, semester: &str) -> Result<()> {
        let conn = self.conn.lock().unwrap();
        conn.execute(
            "
            UPDATE Enrollment
            SET status = '退选'
            WHERE student_id = ?1 AND course_id = ?2 AND semester = ?3
            ",
            params![&student_id, &course_id, &semester],
        )?;
        Ok(())
    }

    pub fn query_courses_by_semester(&self, semester: &str) -> Result<Vec<Course>> {
        let conn = self.conn.lock().unwrap();
        let mut stmt = conn.prepare(
            r"
            SELECT course_id, course_name, teacher_id, classroom, time_slot, semester, credit, capacity
            FROM Course
            WHERE semester = ?1
            ",
        )?;
        let course_iter = stmt.query_map(&[&semester], |row| {
            Ok(Course {
                course_id: row.get(0)?,
                course_name: row.get(1)?,
                teacher_id: row.get(2)?,
                classroom: row.get(3)?,
                time_slot: row.get(4)?,
                semester: row.get(5)?,
                credit: row.get(6)?,
                capacity: row.get(7)?,
            })
        })?;

        let mut courses = Vec::new();
        for course in course_iter {
            courses.push(course?);
        }
        Ok(courses)
    }
}

#[frb(init)]
fn init_database() -> Result<Database> {
    let db = Database::new("aniya.db")?;
    Ok(db)
}

#[frb]
impl Database {
    #[frb]
    pub fn exec_enroll_student(
        &self,
        student_id: i32,
        course_id: i32,
        semester: &str,
    ) -> Result<()> {
        self.enroll_student(student_id, course_id, semester)
            .map_err(|e| e.into())
    }

    #[frb]
    pub fn exec_unenroll_student(
        &self,
        student_id: i32,
        course_id: i32,
        semester: &str,
    ) -> Result<()> {
        self.unenroll_student(student_id, course_id, semester)
            .map_err(|e| e.into())
    }

    #[frb]
    pub fn exec_query_courses_by_semester(&self, semester: &str) -> Result<Vec<Course>> {
        self.query_courses_by_semester(semester)
            .map_err(|e| e.into())
    }

    #[frb]
    pub fn display_path_to_database(&self) {
        match env::current_dir() {
            Ok(path) => println!("当前工作目录: {:?}", path),
            Err(e) => eprintln!("获取当前工作目录时出错: {}", e),
        }
    }

    #[frb]
    pub fn query_enrollments_by_student_and_semester(
        &self,
        student_id: i32,
        semester: &str,
    ) -> Result<Vec<Enrollment>> {
        let conn = self.conn.lock().unwrap();
        let mut stmt = conn.prepare(
            r"
        SELECT enrollment_id, student_id, course_id, semester, status
        FROM Enrollment
        WHERE student_id = ?1 AND semester = ?2
        ",
        )?;
        let enrollment_iter = stmt.query_map(params![&student_id, &semester], |row| {
            Ok(Enrollment {
                enrollment_id: row.get(0)?,
                student_id: row.get(1)?,
                course_id: row.get(2)?,
                semester: row.get(3)?,
                status: row.get(4)?,
            })
        })?;

        let mut enrollments = Vec::new();
        for enrollment in enrollment_iter {
            enrollments.push(enrollment?);
        }
        Ok(enrollments)
    }
}
