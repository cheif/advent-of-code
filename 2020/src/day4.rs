use std::collections::HashMap;
use regex::Regex;
use std::i64;

pub fn run(input: String) -> String {
    return parse(input).iter().map(parse_stringy).flatten().count().to_string();
}

pub fn run_second(input: String) -> String {
    return parse(input).iter().map(parse_stringy).flatten().map(parse_strict).flatten().count().to_string();
}

fn parse(input: String) -> Vec<HashMap<String, String>> {
    return input.split("\n\n").map(get_passport_data).collect();
}

fn get_passport_data(line: &str) -> HashMap<String, String> {
    let without_newlines = line.replace("\n", " ");
    return without_newlines.split(" ").map(pair_from_str).map(|pair| pair.unwrap()).collect();
}

fn pair_from_str(pair: &str) -> Option<(String, String)> {
    let mut split = pair.split(":");
    let key = split.next();
    let val = split.next();
    return key.zip(val).map(|(key, val)| (key.to_string(), val.to_string()) );
}

fn parse_strict(input: StringyPassport) -> Option<StrictPassport> {
    let byr = Year::from_str(&input.byr, 1920, 2002)?;
    let iyr = Year::from_str(&input.iyr, 2010, 2020)?;
    let eyr = Year::from_str(&input.eyr, 2020, 2030)?;
    let hgt = Height::from_str(&input.hgt)?;
    let hcl = HairColor::from_str(&input.hcl)?;
    let ecl = EyeColor::from_str(&input.ecl)?;
    let pid = Pid::from_str(&input.pid)?;
    let result =
        StrictPassport {
            byr: byr,
            iyr: iyr,
            eyr: eyr,
            hgt: hgt,
            hcl: hcl,
            ecl: ecl,
            pid: pid
        };
    return Some(result);
}

fn parse_stringy(input: &HashMap<String, String>) -> Option<StringyPassport> {
    let byr = input.get("byr")?;
    let iyr = input.get("iyr")?;
    let eyr = input.get("eyr")?;
    let hgt = input.get("hgt")?;
    let hcl = input.get("hcl")?;
    let ecl = input.get("ecl")?;
    let pid = input.get("pid")?;
    return Some(
        StringyPassport {
            byr: byr.to_string(),
            iyr: iyr.to_string(),
            eyr: eyr.to_string(),
            hgt: hgt.to_string(),
            hcl: hcl.to_string(),
            ecl: ecl.to_string(),
            pid: pid.to_string()
        }
    )
}

#[derive(Debug)]
struct StringyPassport {
    byr: String,
    iyr: String,
    eyr: String,
    hgt: String,
    hcl: String,
    ecl: String,
    pid: String
}

#[derive(Debug)]
struct StrictPassport {
    byr: Year,
    iyr: Year,
    eyr: Year,
    hgt: Height,
    hcl: HairColor,
    ecl: EyeColor,
    pid: Pid
}

#[derive(Debug)]
struct Year {
    val: i16
}

#[derive(Debug)]
enum Height {
    Metric(i16),
    Imperical(i16)
}

#[derive(Debug)]
struct HairColor {
    val: i64
}

#[derive(Debug)]
enum EyeColor {
    Amb,
    Blu,
    Brn,
    Gry,
    Grn,
    Hzl,
    Oth
}

#[derive(Debug)]
struct Pid {
    val: i64
}

impl Year {
    fn from_str(s: &str, min: i16, max: i16) -> Option<Self> {
        let parsed = s.parse::<i16>().ok()?;

        if parsed >= min && parsed <= max {
            return Some(Year { val: parsed });
        } else {
            return None;
        }
    }
}

impl Height {
    fn from_str(s: &str) -> Option<Self> {
        let re = Regex::new(r"^(\d*)(\w*)").unwrap();
        let m = re.captures_iter(s).next()?;
        let val: i16 = m[1].parse().ok()?;
        let unit: String = m[2].parse().ok()?;
        match (unit.as_str(), val) {
            ("cm", 150..=193) => Some(Self::Metric(val)),
            ("in", 59..=76) => Some(Self::Imperical(val)),
            _ => None
        }
    }
}

impl HairColor {
    fn from_str(s: &str) -> Option<Self> {
        let re = Regex::new(r"^\#(.{6})").unwrap();
        let m = re.captures_iter(s).next()?;
        let val = i64::from_str_radix(&m[1], 16).ok()?;
        return Some(HairColor { val: val });
    }
}

impl EyeColor {
    fn from_str(s: &str) -> Option<Self> {
        match s {
            "amb" => Some(Self::Amb),
            "blu" => Some(Self::Blu),
            "brn" => Some(Self::Brn),
            "gry" => Some(Self::Gry),
            "grn" => Some(Self::Grn),
            "hzl" => Some(Self::Hzl),
            "oth" => Some(Self::Oth),
            _ => None
        }
    }
}

impl Pid {
    fn from_str(s: &str) -> Option<Self> {
        if s.len() != 9 {
            return None
        }
        Some(Pid {
            val: s.parse().ok()?
        })
    }
}
