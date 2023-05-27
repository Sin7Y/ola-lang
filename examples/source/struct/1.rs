// 定义一个简单的结构体
struct Point {
    x: f64,
    y: f64,
}

// 定义一个函数，它接受一个Point作为参数，返回一个Point
fn translate(point: Point, dx: f64, dy: f64) -> Point {
    Point {
        x: point.x + dx,
        y: point.y + dy,
    }
}

fn main() {
    // 创建一个新的Point
    let point = Point { x: 1.0, y: 2.0 };

    // 调用translate函数
    let new_point = translate(point, 1.0, -1.0);

    println!("The new point is at ({}, {})", new_point.x, new_point.y);
}
