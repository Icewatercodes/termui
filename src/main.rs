use terminal_size::{ terminal_size, Width, Height};

fn gen_border(w: u16, h: u16, title: &str) -> String {
    let mut out = String::from("\x1b[H┌");
    
    for _ in 2..w - (title.len() as u16) { 
        out.push('─'); 
    }
    out.push('┐')
    
    for i in 2..h-2 {
        let temp = format!("\x1b[{};0f│\x1b[{}G│", i, w);
        out.push_str(&temp);
    }
    
    let temp = format!("\x1b[{}G┘\x1b[0G└", w);
    out.push_str(&temp);
    
    for _ in 2..w { 
        out.push('─'); 
    }
    
    return String::from(out);
}

fn main() {
    let size = terminal_size();
    let Some((Width(w), Height(h))) = size else { //get the terminal height and width
        println!("error");
        return; 
    }
    
    println!("\x1b[2J");
    println!("{}", gen_border(w, h, "title"));
    
    
            
}
