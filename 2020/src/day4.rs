use std::str::FromStr;
use std::collections::HashMap;
use std::ops::RangeInclusive;
use std::marker::PhantomData;
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
    return Some(StrictPassport {
        byr: input.byr.parse().ok()?,
        iyr: input.iyr.parse().ok()?,
        eyr: input.eyr.parse().ok()?,
        hgt: input.hgt.parse().ok()?,
        hcl: input.hcl.parse().ok()?,
        ecl: input.ecl.parse().ok()?,
        pid: input.pid.parse().ok()?
    });
}

fn parse_stringy(input: &HashMap<String, String>) -> Option<StringyPassport> {
    return Some(
        StringyPassport {
            byr: input.get("byr")?.to_string(),
            iyr: input.get("iyr")?.to_string(),
            eyr: input.get("eyr")?.to_string(),
            hgt: input.get("hgt")?.to_string(),
            hcl: input.get("hcl")?.to_string(),
            ecl: input.get("ecl")?.to_string(),
            pid: input.get("pid")?.to_string()
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
    byr: Year<BirthYearValidity>,
    iyr: Year<IssueYearValidity>,
    eyr: Year<ExpiryYearValidity>,
    hgt: Height,
    hcl: HairColor,
    ecl: EyeColor,
    pid: Pid
}

#[derive(Debug)]
struct Year<V: ?Sized> {
    val: i16,
    phantom: PhantomData<V>
}

trait Validity {
    fn range() -> RangeInclusive<i16> where Self: Sized;
}

#[derive(Debug)]
struct BirthYearValidity {}
impl Validity for BirthYearValidity {
    fn range() -> RangeInclusive<i16> {
        return 1920..=2002;
    }
}

#[derive(Debug)]
struct IssueYearValidity {}
impl Validity for IssueYearValidity {
    fn range() -> RangeInclusive<i16> {
        return 2010..=2020;
    }
}

#[derive(Debug)]
struct ExpiryYearValidity {}
impl Validity for ExpiryYearValidity {
    fn range() -> RangeInclusive<i16> {
        return 2020..=2030;
    }
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

impl<V> FromStr for Year<V> where V: Validity {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let range = V::range();
        let parsed = s.parse::<i16>().map_err(|_| ())?;

        if range.contains(&parsed) {
            return Ok(Year { val: parsed, phantom: PhantomData });
        } else {
            return Err(());
        }
    }
}

impl FromStr for Height {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re = Regex::new(r"^(\d*)(\w*)").unwrap();
        let m = re.captures_iter(s).next().ok_or(())?;
        let val: i16 = m[1].parse().map_err(|_| ())?;
        let unit: String = m[2].parse().map_err(|_| ())?;
        match (unit.as_str(), val) {
            ("cm", 150..=193) => Ok(Self::Metric(val)),
            ("in", 59..=76) => Ok(Self::Imperical(val)),
            _ => Err(())
        }
    }
}

impl FromStr for HairColor {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re = Regex::new(r"^\#(.{6})").unwrap();
        let m = re.captures_iter(s).next().ok_or(())?;
        let val = i64::from_str_radix(&m[1], 16).map_err(|_| ())?;
        return Ok(HairColor { val: val });
    }
}

impl FromStr for EyeColor {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "amb" => Ok(Self::Amb),
            "blu" => Ok(Self::Blu),
            "brn" => Ok(Self::Brn),
            "gry" => Ok(Self::Gry),
            "grn" => Ok(Self::Grn),
            "hzl" => Ok(Self::Hzl),
            "oth" => Ok(Self::Oth),
            _ => Err(())
        }
    }
}

impl FromStr for Pid {
    type Err = ();
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if s.len() != 9 {
            return Err(())
        }
        Ok(Pid {
            val: s.parse().map_err(|_| ())?
        })
    }
}
