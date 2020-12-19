pub fn run(input: String) -> Vec<usize> {
    return vec![
        input.lines().map(process).sum(),
        // This doesn't work :(
        input.lines().map(process_second).sum()
    ];
}

fn process(line: &str) -> usize {
    let tokens = LeftToRightTokenizer::tokenize(line);
    let expr = LeftToRightTokenizer::process(tokens);
    return expr.eval();
}

fn process_second(line: &str) -> usize {
    println!("text: {}", line);
    let tokens = PlusTokenizer::tokenize(line);
    println!("tokens: {:?}", tokens);
    let plus_parens = PlusTokenizer::replace_plus(tokens);
    println!("plus_tokens: {:?}", plus_parens);
    let expr = PlusTokenizer::process(plus_parens);
    println!("expr: {:?}", expr);
    println!("res: {}\n", expr.eval());
    return expr.eval();
}

#[derive(Debug, Clone)]
enum Expr {
    Raw(usize),
    Plus(Box<Expr>, Box<Expr>),
    Times(Box<Expr>, Box<Expr>)
}

#[derive(Debug, Clone)]
enum Token {
    Num(usize),
    Plus,
    Times,
    Paren(Vec<Token>)
}

trait Tokenizer {
    fn tokenize(text: &str) -> Vec<Token> {
        //println!("text: {}", text);
        let chars: Vec<char> = text.replace(" ", "").chars().collect();
        return Self::parse(chars);
    }

    fn parse(chars: Vec<char>) -> Vec<Token> {
        //println!("parse: {:?}", chars);
        let mut tokens: Vec<Token> = vec![];
        let mut i = 0;
        while i < chars.len() {
            //println!("c: {}", chars[i]);
            match chars[i] {
                '+' => tokens.push(Token::Plus),
                '*' => tokens.push(Token::Times),
                '(' => {
                    let closing = Self::matching_close_paren(&chars[i+1..]) + i;
                    let inside: Vec<char> = chars[i+1..closing].to_vec();
                    //println!("{}:{} -> {:?}", i, closing, inside);
                    tokens.push(Token::Paren(Self::parse(inside)));
                    i += closing - i;
                },
                c => tokens.push(Token::Num(c.to_digit(10).unwrap() as usize)),
                _ => panic!()
            }
            i += 1;
        }
        return tokens;
    }

    fn matching_close_paren(chars: &[char]) -> usize {
        //println!("match: {:?}", chars);
        let mut paren_count = 1;
        let mut i: usize = 0;
        while paren_count > 0 {
            let next = chars[i];
            if next == '(' {
                paren_count += 1;
            } else if next == ')' {
                paren_count -= 1;
            }
            i += 1;
        }
        return i;
    }

    fn process(tokens: Vec<Token>) -> Expr;

    fn expr(token: &Token) -> Expr {
        return match token {
            Token::Num(num) => Expr::Raw(*num),
            Token::Paren(inside) => Self::process(inside.to_vec()),
            _ => panic!()
        }
    }
}

struct LeftToRightTokenizer;

impl Tokenizer for LeftToRightTokenizer {
    fn process(tokens: Vec<Token>) -> Expr {
        if tokens.len() == 1 {
            return Self::expr(&tokens[0]);
        }
        //println!("process: {:?}", tokens);
        let lhs = Box::new(Self::process(tokens[0..tokens.len()-2].to_vec()));
        let op = &tokens[tokens.len()-2];
        let rhs = Box::new(Self::process(tokens[tokens.len()-1..].to_vec()));
        return match op {
            Token::Plus => Expr::Plus(lhs, rhs),
            Token::Times => Expr::Times(lhs, rhs),
            _ => panic!()
        }
    }
}

struct PlusTokenizer;

impl Tokenizer for PlusTokenizer {
    fn process(tokens: Vec<Token>) -> Expr {
        if tokens.len() == 1 {
            return Self::expr(&tokens[0]);
        }
        //println!("process: {:?}", tokens);
        let lhs = Box::new(Self::process(tokens[0..tokens.len()-2].to_vec()));
        let op = &tokens[tokens.len()-2];
        let rhs = Box::new(Self::process(tokens[tokens.len()-1..].to_vec()));
        return match op {
            Token::Plus => Expr::Plus(lhs, rhs),
            Token::Times => Expr::Times(lhs, rhs),
            _ => panic!()
        }
    }
}

impl PlusTokenizer {
    fn replace_plus(tokens: Vec<Token>) -> Vec<Token> {
        if !Self::contains_plus(&tokens) {
            return tokens;
        }
        let mut output: Vec<Token> = vec![];
        let mut i = 0;
        while i < tokens.len() {
            match tokens.get(i+1) {
                Some(Token::Plus) => {
                    let inner: Vec<Token> = tokens[i..i+3].into_iter().map(|t| match t {
                        Token::Paren(cnt) => Token::Paren(Self::replace_plus(cnt.to_vec())),
                        _ => t.clone()
                    }).collect();
                    output.push(Token::Paren(inner));
                    i += 3;
                },
                _ => {
                    let content = match &tokens[i] {
                        Token::Paren(inner) => Token::Paren(Self::replace_plus(inner.to_vec())),
                        _ => tokens[i].clone()
                    };
                    output.push(content);
                    i += 1;
                }
            }
        }
        return Self::replace_plus(output);
    }

    fn contains_plus(tokens: &Vec<Token>) -> bool {
        return tokens.iter().any(|t| match t {
            Token::Plus => true,
            Token::Paren(inner) => if inner.len() > 3 { Self::contains_plus(inner) } else { false },
            _ => false
        });
    }
}

impl Expr {
    fn eval(&self) -> usize {
        return match self {
            Expr::Raw(n) => *n,
            Expr::Plus(lhs, rhs) => lhs.eval() + rhs.eval(),
            Expr::Times(lhs, rhs) => lhs.eval() * rhs.eval()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_process() {
        assert_eq!(process("1 + 2 * 3 + 4 * 5 + 6"), 71);
        assert_eq!(process("1 + (2 * 3) + (4 * (5 + 6))"), 51);
        assert_eq!(process("2 * 3 + (4 * 5)"), 26);
        assert_eq!(process("5 + (8 * 3 + 9 + 3 * 4 * 3)"), 437);
        assert_eq!(process("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"), 12240);
        assert_eq!(process("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"), 13632);
    }

    #[test]
    fn test_process_second() {
        assert_eq!(process_second("1 + 2 * 3 + 4 * 5 + 6"), 231);
        assert_eq!(process_second("1 + (2 * 3) + (4 * (5 + 6))"), 51);
        assert_eq!(process_second("2 * 3 + (4 * 5)"), 46);
        assert_eq!(process_second("5 + (8 * 3 + 9 + 3 * 4 * 3)"), 1445);
        assert_eq!(process_second("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"), 669060);
        assert_eq!(process_second("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"), 23340);
    }
}
