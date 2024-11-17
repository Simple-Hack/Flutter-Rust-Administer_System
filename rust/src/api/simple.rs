use flutter_rust_bridge::frb;
use rusqlite::{params, Connection, Result};

#[frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[frb(sync)]
pub fn get_platform_version() -> String {
    format!("{} {}", std::env::consts::OS, std::env::consts::ARCH)
}

#[frb(serialize)]
pub struct Grade {
    pub course_id: i32,
    pub course_name: String,
    pub score: f64,
    pub gpa: f64,
    pub semester: String,
    pub student_id: i32,
}

#[frb(sync)]
pub fn fetch_grades(semester: String, student_id: i32) -> Result<Vec<Grade>, String> {
    // 构建完整的文件路径
    let db_path = "D:\\VsFile\\Flutter\\SoftwareDemo\\my_final_web\\aniya.db";

    // 打开数据库连接
    let conn = Connection::open(db_path).map_err(|e| e.to_string())?;

    let query = if semester == "All" {
        "SELECT * FROM grades WHERE studentId = ?"
    } else {
        "SELECT * FROM grades WHERE semester = ? AND studentId = ?"
    };

    let mut stmt = conn.prepare(&query).map_err(|e| e.to_string())?;
    let mut grades_iter = if semester == "All" {
        stmt.query(&[&student_id]).map_err(|e| e.to_string())? // 使用 student_id 作为参数
    } else {
        stmt.query(params![&semester, &student_id])
            .map_err(|e| e.to_string())? // 使用 semester 和 student_id 作为参数
    };

    let mut grades = Vec::new();
    while let Some(row) = grades_iter.next().map_err(|e| e.to_string())? {
        grades.push(Grade {
            course_id: row.get(1).map_err(|e| e.to_string())?,
            course_name: row.get(2).map_err(|e| e.to_string())?,
            score: row.get(3).map_err(|e| e.to_string())?,
            gpa: row.get(4).map_err(|e| e.to_string())?,
            semester: row.get(5).map_err(|e| e.to_string())?,
            student_id: row.get(6).map_err(|e| e.to_string())?, // 获取 student_id
        });
    }

    Ok(grades)
}
