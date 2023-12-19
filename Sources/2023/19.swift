import Foundation
import Shared

private struct Workflow {
    let name: String
    let rules: [Rule]

    struct Rule {
        let target: Res
        let category: Character?
        let range: Range<Int>?

        init(string: String.SubSequence) {
            let split = string.split(separator: ":")
            let targetString: String
            if split.count > 1 {
                targetString = String(split[1])
                let key = split[0].first!
                let comp = Int(split[0].dropFirst(2))!
                category = key
                range = switch split[0].dropFirst().first! {
                case "<": 1..<comp
                case ">": comp..<4001
                default: fatalError()
                }
            } else {
                targetString = String(split[0])
                category = nil
                range = nil
            }

            target = switch targetString {
            case "A": .accepted
            case "R": .rejected
            default: .send(targetString)
            }
        }

        func process(_ part: [Character: Int]) -> Res? {
            guard let category, let range else {
                return target
            }
            if range.contains(part[category]!) {
                return target
            } else {
                return nil
            }
        }
    }

    enum Res {
        case send(String)
        case accepted
        case rejected
    }

    func process(_ part: [Character: Int]) -> Res {
        rules.compactMap { $0.process(part) }.first!
    }

    init(line: String.SubSequence) {
        let split = line.split(separator: "{")
        self.name = String(split[0])
        self.rules = split[1].dropLast().split(separator: ",").map(Rule.init)
    }
}

private typealias Possibilities = [Character: Range<Int>]
private func splitPossibilities(_ possibilities: Possibilities, rule: Workflow.Rule) -> (Possibilities, Possibilities) {
    guard let category = rule.category,
          let ruleRange = rule.range else {
        return ([:], possibilities)
    }
    let left = Dictionary(uniqueKeysWithValues: possibilities.compactMap { cat, range in
        if cat == category {
            if range.contains(ruleRange.upperBound) {
                return (cat, ruleRange.upperBound..<range.upperBound)
            } else if range.contains(ruleRange.lowerBound) {
                return (cat, range.lowerBound..<ruleRange.lowerBound + 1)
            } else {
                return (cat, 1..<1)
            }
        } else {
            return (cat, range)
        }
    })
    let consumed = Dictionary(uniqueKeysWithValues: possibilities.compactMap { cat, range in
        if cat == category {
            if range.contains(ruleRange.upperBound) {
                return (cat, range.lowerBound..<ruleRange.upperBound)
            } else if range.contains(ruleRange.lowerBound) {
                return (cat, (ruleRange.lowerBound + 1)..<range.upperBound)
            } else {
                return (cat, 1..<1)
            }
        } else {
            return (cat, range)
        }
    })
    return (left, consumed)
}

public let day19 = Solution(
    part1: { input in
        let split = input.split(separator: "\n\n")
        let rules = split[0].split(whereSeparator: \.isNewline).map { Workflow(line: $0) }
            .grouped(by: \.name)
            .mapValues { $0.first! }
        let parts = split[1].split(whereSeparator: \.isNewline).map { line in
            let splits = line.dropFirst().dropLast().split(separator: ",")
            return Dictionary(
                splits.map { attrs in
                    let split = attrs.split(separator: "=")
                    return (split[0].first!, Int(String(split[1]))!)
                }, uniquingKeysWith: { lhs, _ in lhs }
            )
        }
        let accepted = parts.filter { part in
            var res = Workflow.Res.send("in")
            while true {
                switch res {
                case .send(let string):
                    res = rules[string]!.process(part)
                case .accepted:
                    return true
                case .rejected:
                    return false
                }
            }
        }
        return accepted.map { $0.map { _, val in val }.sum }.sum
    },
    part2: { input in
        let split = input.split(separator: "\n\n")
        let workflows = split[0].split(whereSeparator: \.isNewline).map { Workflow(line: $0) }
            .grouped(by: \.name)
            .mapValues { $0.first! }

        func accepted(workflow: Workflow, possibilities: [Character: Range<Int>]) -> Int {
            return workflow.rules.reduce((possibilities: possibilities, accepted: 0)) { acc, rule in
                let (left, consumed) = splitPossibilities(acc.possibilities, rule: rule)
                switch rule.target {
                case .rejected:
                    return (left, acc.accepted)
                case .accepted:
                    return (left, acc.accepted + consumed.map(\.value.count).reduce(1, *))
                case .send(let name):
                    return (left, acc.accepted + accepted(workflow: workflows[name]!, possibilities: consumed))
                }
            }.1
        }

        let allPossible = [
            "x".first!: 1..<4001,
            "m".first!: 1..<4001,
            "a".first!: 1..<4001,
            "s".first!: 1..<4001,
        ]
        return accepted(workflow: workflows["in"]!, possibilities: allPossible)
    },
    testResult: (19114, 167409079868000),
    testInput: #"""
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""#,
    input: #"""
qq{m<124:cln,s>2278:ngs,flb}
zpg{s<2205:R,A}
sqc{s<3500:tt,a>3595:vcv,msq}
mxk{a<3598:R,R}
rl{s>3383:R,s>3213:A,A}
jkf{x<1611:A,m>2419:A,a<3305:A,R}
fg{s>2520:klk,s<2081:xv,R}
hs{s>466:kv,ks}
vhk{x>372:A,jqj}
cf{x>304:R,A}
jbn{x>3003:A,rgz}
tc{s<441:R,R}
dh{m>2530:tr,A}
vz{s<808:fl,x<1142:R,bc}
mt{x>2677:A,m<1517:R,a>3096:R,A}
bh{a<1985:R,R}
vns{m>1190:xxl,x>1874:R,a>2111:dfq,A}
bns{s>1309:A,s>1016:R,R}
gnn{s<2045:vm,m<1120:R,A}
gxs{x>2353:rp,dsj}
xtn{m>780:A,R}
jtj{a<403:R,a<710:jhv,s>2646:gt,A}
vfd{x<3531:R,x>3697:A,A}
th{s>3251:rd,prz}
bbk{x>2564:nr,m>844:A,A}
pc{a<717:nn,s>1340:R,rh}
lcm{m<318:R,m<357:xps,x<2342:A,ptz}
zxg{a<1397:R,A}
fx{a>3110:tsg,m<1200:nqz,x>693:qgr,gkc}
jqj{s<3265:A,m<352:R,a<2123:A,R}
gcm{a>2418:A,zrr}
hn{s<3612:A,A}
prh{a>3047:A,m>1086:R,R}
vlv{x>1193:R,R}
dv{s>3789:R,m<721:A,A}
rc{s>358:fm,a<3107:psv,m<2563:R,dn}
ns{s>857:rn,x>2466:hs,m<2861:rvr,mg}
gt{a<852:A,A}
rgz{a>1013:R,x<2875:R,A}
tmh{m<1289:R,A}
qp{a>3693:fqf,R}
sjh{x<2554:pnh,zzs}
qx{m>95:A,s>1748:R,A}
jrq{s>383:ls,glt}
qtz{m<1232:R,x>118:A,x<48:A,A}
xqj{s>2609:R,s>2220:A,s<1882:R,A}
cnj{m<837:A,m>953:A,A}
rfd{m>409:A,A}
mj{m<1083:R,m>1143:R,m<1117:R,A}
zrr{s>3159:R,x<649:A,m<1930:R,R}
vd{a<619:A,s>1355:rs,thz}
psv{a<2658:R,A}
km{x<887:A,A}
lk{s<3018:A,s<3214:A,A}
bx{m<3605:dp,s>796:tpc,s>736:tl,A}
xbb{x>1990:R,A}
ljr{a>1453:A,a<664:A,s>826:R,R}
pxc{x<3410:mv,A}
pz{a<1021:vd,dh}
tsq{a<2081:td,x<3227:A,a>2737:A,A}
ndk{a>2912:A,x<3692:A,R}
pmx{s>1991:R,x<925:A,A}
mb{m<762:A,R}
rqr{a>3566:lkn,a>3365:km,R}
jbh{s>3368:A,x>966:A,x<609:R,A}
sj{x>426:A,m<1035:A,x<382:R,A}
nkg{a<1481:A,A}
dzz{x>1787:R,x<1661:A,s<1983:R,R}
tj{s<1421:R,R}
ggq{a<3565:A,a<3673:A,x>1988:A,A}
lq{x>551:vz,s<965:cz,s<1430:mc,hvz}
rx{a<124:A,s<3662:R,R}
qgk{a<41:kjf,xp}
jt{x<2480:R,x>3296:R,A}
vxn{a>3362:R,s<2834:A,R}
fbg{s<387:R,a>2827:A,a>2450:R,A}
kxz{a>222:A,m>722:A,s>3555:R,A}
ngs{a<1478:A,A}
rfz{s>1384:A,R}
ln{a<3096:A,x>2407:R,A}
rxd{a<2871:A,s<186:R,R}
dm{a<2822:A,m<1559:dzz,m>1662:rql,glh}
gd{m<1204:jn,qqm}
bgv{a>3681:A,a>3496:R,x>2728:A,R}
zld{m>1547:A,A}
hc{a<528:A,R}
rvr{a<2846:hzv,x<1787:jkf,x<2087:nh,lz}
ff{s<2834:A,m<1066:A,x>3407:R,A}
lmz{m>1324:A,x<2306:R,A}
xr{x>482:tpd,hbb}
fv{x>2322:A,m<1171:A,R}
rgm{x>727:fhl,m<327:tj,nt}
zn{m<934:nsd,A}
bjm{x>2872:tn,a<392:A,gq}
mf{x<2780:gvc,x>3259:bs,a>625:chc,lb}
hxq{a<1254:rqc,s<3467:R,m>794:ssm,dv}
rf{s<1024:R,qjh}
mfl{s>1795:R,m<310:A,xgc}
zm{x<2067:rb,m<2243:cb,A}
kfb{s>1924:R,xmc}
ss{x>209:R,x<83:R,m<1346:bf,mks}
zzs{s<1996:R,m<3275:A,m<3657:A,A}
rpm{x>3019:A,x>2879:R,x>2821:R,A}
nv{a<2055:R,A}
dsj{a>2870:qxp,s<2558:qxq,a<2508:xtn,xbb}
lkx{a>466:pdz,qkb}
tl{a>1430:A,A}
mrs{s<3460:A,jq}
rn{a<3242:xz,m<3049:hk,mvt}
rls{s>1992:R,x<3232:R,A}
zfl{x<342:hgd,a>3184:dhv,x<540:grt,lh}
pxx{m>395:zl,m<236:qq,a<1341:jgx,rm}
ffl{s<3538:R,s>3703:R,m>340:R,A}
nxc{x<1729:R,R}
gm{m>604:R,a<143:R,A}
mxv{m>3188:A,R}
kj{m<3136:A,s<1161:R,s>1526:A,A}
rtg{s<1804:A,R}
cx{m<1217:R,A}
hnb{m<358:A,a<1155:R,a<1244:R,A}
mtb{s>481:A,m<2460:A,s<209:A,A}
kff{a>1343:gff,x>2311:px,m<494:A,A}
zv{m>173:prx,x<3121:qx,x>3495:hhb,dbj}
bf{x>144:R,m<967:R,m>1095:A,R}
qjp{x<3358:A,rjj}
jm{x>747:pj,zfl}
fr{m<518:A,a<3852:A,s<1823:A,A}
bjs{s<382:A,R}
ths{a>1275:R,R}
vm{m<1050:A,s>1802:R,R}
vkd{s>3699:R,m>1661:R,m>1657:A,R}
zq{a>1445:fx,a>573:xr,a>207:tz,pds}
bxq{s<2987:A,x>2945:A,m>2477:hn,A}
kfp{s<2067:hx,x<2905:mjh,qh}
fhk{a>616:A,A}
sm{x<2911:A,m<2998:R,A}
dr{m>423:dfd,m>244:rgm,qdc}
jc{m<296:tgc,m<329:A,m<368:R,R}
dvm{m<2892:bdq,s<687:xsv,bx}
dn{x>1227:A,R}
xhf{s<291:R,A}
hb{s<187:R,x>1651:mxv,x>1512:R,A}
thz{s<1094:R,s>1208:A,A}
lf{x<1807:R,R}
kt{m>629:R,s<1410:A,A}
ht{m>1527:A,R}
lb{x>3046:rsr,bjm}
drm{s<3561:A,m>1576:ln,kg}
zt{m>1215:rzb,x>1379:jrq,x>500:cpg,hgt}
zqx{x>857:R,m>583:R,R}
zg{s<1905:A,a>1876:A,R}
nrp{a>2363:A,x<1949:R,s>353:R,R}
vf{a>1843:jbh,a>641:hdr,R}
jkj{x>2189:njq,a<906:lpz,ch}
ztt{a>1528:pxh,a<1377:R,R}
pjp{s<1463:R,a>3119:A,x<2392:R,R}
xvq{a>3038:R,a<2716:R,A}
fn{a<2943:R,R}
tf{m>1626:dlz,s>3304:drm,x<2822:fq,qjp}
srj{a<1910:A,x>590:R,A}
qnf{a>472:R,x<1093:A,A}
zl{s>2057:jht,kff}
xp{m>1276:R,x>1131:A,R}
fp{a>3303:R,R}
fqb{s<3164:cjs,vjx}
td{a<1177:A,R}
rql{x<2044:R,a>3496:R,R}
np{a>1991:A,R}
ntv{a<1430:xj,A}
zj{m>2552:jrs,s>177:qft,fqs}
hkk{s>3106:R,x<1911:A,s>3030:A,R}
lx{s>3328:A,x>3075:R,m<1282:jlj,lmz}
pds{x>913:bdt,mh}
msq{s>3758:A,m<598:R,R}
gx{a<3706:A,m>3342:A,a>3847:A,A}
fq{s>2904:hkk,a<3172:vx,m<1571:fj,A}
dnq{a>1192:R,m<282:A,s>751:R,A}
vrc{s<2718:R,m>569:A,R}
rbc{m<3801:mrs,tsq}
dp{a>1019:R,x<2964:R,x>3536:A,R}
dfm{a<454:A,A}
qgr{m>1464:fdd,x<1064:zhg,x<1264:vlv,fg}
jn{m<971:gxs,x>2623:sr,a>2847:ld,dhb}
dtr{a>846:vt,A}
xnh{s>2928:R,m>2462:mzl,gh}
gbh{a>2860:dmk,R}
rh{x>1962:A,a>884:A,m>1283:A,R}
cqg{s>1074:A,s<1009:bj,A}
krf{s<2703:A,x>844:R,R}
xsv{m<3372:R,ll}
ntf{m>395:R,A}
tkz{a>1158:sd,a>1097:bt,a>1025:A,tlc}
chb{m>1102:A,x<1184:A,A}
mg{s>539:tzb,x>2016:rxd,m<3416:hb,xbr}
rsr{x>3175:R,x>3125:R,x>3074:A,R}
nc{a<1746:tg,cqb}
mc{s>1261:kdh,x<287:A,pb}
zp{m<459:R,m>470:A,A}
gff{m<525:A,s<955:A,R}
sz{s<1505:rt,x<1420:zq,a>2173:gd,ntm}
qhp{m>482:R,a>3481:bbd,zp}
scp{m<343:A,a>3576:R,R}
bs{x<3708:jtj,dfm}
zpd{s<2641:A,a>3649:R,x>1808:A,R}
kch{m<495:A,a>3358:A,R}
pxh{a>1769:R,s<2378:A,R}
hp{m>375:rtg,a>3294:scp,R}
prx{a>3091:R,s<1699:R,a>2403:R,jnl}
qxq{s>2201:A,A}
klk{x<1323:R,s>3383:R,x>1371:R,R}
bbd{s<3698:R,A}
hf{x>1060:A,A}
pgv{x>1739:A,m<1721:R,A}
kpg{x<2127:A,s<2348:R,a<758:R,R}
qf{m>1314:A,m<1037:A,mn}
mkf{m<1417:srj,csb}
dkp{x>1917:A,R}
rp{s>2871:zh,mb}
jf{s<3124:R,s>3145:R,m>2988:R,R}
xqx{m<811:R,x<2084:A,m<948:R,A}
qng{a>2081:R,a>1837:A,x>936:A,A}
chc{a<868:mfl,a<946:zgm,a>1000:jbn,spd}
qnq{m>568:R,bvd}
zc{s<455:A,A}
mvt{m>3633:R,gx}
tg{a>1031:pxx,x<1626:qkr,mf}
ps{m<1395:A,m<1564:A,a<765:A,A}
mhq{x>1140:R,s>1385:R,A}
jmq{s<3074:vxn,R}
nm{s>1659:A,a<1639:R,A}
ntm{s<3024:khz,a>908:ffn,lkx}
zcg{s>3555:cr,a<365:R,m<1210:A,qkt}
fcx{m>1712:A,A}
prz{a<1950:R,R}
xc{m>1497:hnn,m>1390:R,s<2173:kmr,pch}
rmr{a<1701:A,R}
pdm{s>2129:R,m>92:R,m<83:A,R}
px{x>3173:A,m<503:R,a<1203:A,A}
jnl{s<2891:A,x>3216:A,A}
xv{x<1328:R,s<1886:A,R}
qkz{a>248:A,A}
rqc{x<2656:R,A}
dk{s>3461:lt,a<2963:dqg,jmq}
rzb{x<2285:R,A}
dj{a>800:R,A}
jtm{a>3279:R,A}
hgr{x<1371:A,R}
nnr{s>2293:R,s>2192:A,R}
fqs{s>103:A,dj}
lt{s>3777:R,fcx}
bdt{s<2481:gxl,a<74:qgk,bsk}
mrg{s>3501:kk,x>2191:bfx,a>239:jj,R}
gjr{s>3138:lj,R}
vl{s>3133:R,R}
zf{m<1034:A,s>1789:R,x>2747:hkg,nm}
rrl{a>3092:klh,s<2055:vgh,df}
ltb{s<3051:bn,s>3182:bh,jf}
rm{a>1498:vs,s>2424:lcm,ntv}
cz{x<208:ctv,ttg}
dqt{a>3689:R,m>3136:A,R}
xmc{a<3345:A,R}
gvc{x>2201:skf,m<380:ptx,dkp}
spd{m>312:R,svt}
pm{s<1803:hgh,gfc}
vcr{s<3216:A,R}
vs{a<1643:dxs,jt}
ng{x<3135:bnl,a>1105:nkg,R}
gqs{m>1468:R,R}
pj{s>921:mhq,x>1039:rc,bds}
vsd{s>3368:A,vlp}
mjh{a>323:fv,s<2389:zpg,pq}
jth{a>1900:R,m>2883:A,A}
xj{m<337:A,A}
kk{a>304:R,R}
mn{x>573:A,a>3549:R,m<1151:A,R}
khz{a>1112:xt,a>636:vq,kfp}
ls{a>3452:A,m<1024:R,R}
sc{s<1996:R,R}
crh{m>1180:R,x<1333:R,a<257:R,A}
pkh{a>315:A,x>1206:crh,qkz}
mks{m<1571:R,R}
xz{s<1464:R,s>1612:A,m<2600:snb,A}
fdd{m<1615:xqj,qng}
sd{x>1040:A,A}
ztc{x<569:A,a<2818:R,m>1428:A,A}
qkt{s>3318:R,s<3216:R,A}
mx{a<2344:R,m<376:R,R}
cgr{m>875:A,kxz}
sgv{s>2367:tmh,s>1876:A,A}
vq{x>2492:dtr,a>949:qz,m>1264:xc,pl}
jsg{a<2736:A,fn}
rlh{m>854:hgr,np}
nvm{x<461:jx,m<275:dgd,a<3565:kch,fr}
tn{a<273:A,R}
ll{a<772:A,a>1508:R,m>3697:R,R}
ck{x<2065:mvc,a>2397:R,m<1090:A,A}
bxj{m<74:R,A}
rzm{m>100:R,m<40:A,R}
rk{x>3488:R,a>1564:rls,R}
vcv{a>3782:R,R}
rvk{m>1376:A,rl}
fb{a<2018:R,a>2279:R,a<2122:nv,A}
vp{s>2094:A,x<671:A,x>948:A,A}
fm{a<2858:A,m>2756:R,A}
kv{a<3302:A,fc}
ghs{a>3560:R,m>98:A,R}
xt{s>2503:lgt,s>2132:ztt,zf}
kkr{a<3485:A,x>2681:R,m>337:R,R}
fl{a<1006:A,s>465:A,a<1436:A,A}
xlr{a<2023:A,vp}
df{a>2219:lmx,x>1080:th,a>2011:vhk,cdz}
kjf{m<1281:R,x<1139:A,m<1574:R,R}
skf{s>2407:thd,s>907:ljf,R}
jqn{x<1351:R,m<532:R,A}
cpq{m<1330:R,s>3552:R,x<2346:R,R}
nfs{a<103:R,x<1197:R,A}
zgm{s>1609:R,a>895:rpm,s>771:fbv,R}
ft{s<1940:xdk,s<3222:vrc,m>561:sqc,qhp}
ljn{m>241:rjk,m<150:ghs,zpd}
dhb{s<2952:gnn,a>2557:vgm,ck}
hdn{m>2166:gn,a>1569:js,jkj}
bz{x>3375:R,sm}
hnc{s>1803:R,m<1413:A,A}
pd{x<1087:R,m>1058:R,s>3567:A,A}
nt{a>328:A,a>144:A,R}
qpc{s<2702:A,R}
pb{a>1087:A,a<490:A,m>2596:A,R}
cm{a>2822:A,m>2634:R,a>2546:A,A}
qqm{s<2546:zqj,m<1543:hsr,m>1669:dk,tf}
tpd{a<975:tcl,s>2391:cd,m<1245:jxr,tkz}
qjh{s>1083:R,a>748:R,R}
pl{a>791:R,a>737:kpg,s<2314:A,R}
cjs{m>1096:R,A}
tt{m<591:A,s<3406:R,R}
hbb{s>2863:nd,tm}
xx{x>835:tkm,A}
vt{x<3117:R,A}
sgg{s<922:knv,s>1186:cgc,m>1211:mnl,dd}
hhb{a>3090:R,s>2294:R,A}
db{a>907:R,m>1039:A,xqx}
jx{x<174:A,s<1687:R,x<345:R,R}
tk{s<3349:ltb,a>2168:bz,ng}
in{m>1770:pm,m>644:sz,nc}
dg{s<1321:R,s<1439:ht,s<1480:pjp,jtm}
pq{a<182:A,s>2730:A,x<2209:R,A}
sp{s<171:R,R}
lks{s>1238:fp,A}
cqb{x<2466:rrl,dbv}
mv{x>2777:R,a<2840:A,m>1295:A,A}
bdq{s>729:ljr,m<2160:R,gpl}
ms{m<472:fk,x<3031:qnq,kqz}
fj{a>3510:A,m<1555:R,m<1562:R,R}
bds{a<3285:fbg,x<921:dqt,bjs}
rfv{x<1147:R,s>1720:R,a>1052:A,R}
fd{m>136:R,A}
mgx{s>3206:A,R}
lpz{m>1975:jsc,m<1839:krf,m<1929:rrf,A}
dhv{x<481:sx,A}
xxl{a<1909:A,a<2307:R,s>1360:A,A}
sgh{a<3232:A,a<3677:A,m>1000:R,R}
hsr{m>1379:nl,lx}
dvq{a>90:R,a<44:R,m>1617:A,A}
md{x>290:R,A}
nsd{m<828:R,s<1139:A,x>1449:A,R}
dqg{s<3087:R,x>2359:R,a<2554:pgv,lf}
xgc{m<509:R,s<742:R,s<1146:A,A}
qft{x>2942:R,a<1346:A,R}
sb{m>3402:R,s>1558:A,R}
rrf{a<473:R,x<1048:R,s<2912:A,A}
qz{m<1109:ztr,A}
klh{x>1174:ljn,x>713:rqr,nvm}
jgx{s>1944:jc,m<310:hl,jvn}
vzv{s>2367:R,R}
ndf{s<3464:R,a<1055:R,A}
bq{x>2614:vl,x>2231:A,x<2077:qpc,R}
mnl{x>2391:vg,x<1078:cqg,sl}
gxl{m>1060:nfs,a>118:A,a<59:A,A}
nd{a<924:A,cx}
kf{m<1011:A,a<2322:R,R}
gn{m<2380:zm,a<1887:xnm,x>2388:bxq,xnh}
xbr{m<3760:A,a<3128:A,a<3532:fcf,R}
fh{s>3358:A,R}
dfs{s>958:dqq,zt}
bc{s<1370:R,a<1209:R,s<1574:A,R}
hgh{a<2217:htd,x>1358:ns,jm}
jht{s<3025:R,a<1338:A,hd}
cpg{m>928:A,hf}
xdk{x>3294:A,s<771:A,bns}
sjm{s<3507:R,A}
vlp{a>2360:A,R}
xps{x<2063:A,x<3342:A,R}
zqj{x<2412:dm,m<1421:pxc,xns}
mbh{s<2592:A,s<3353:R,thx}
fvz{m<1079:cnj,m<1477:R,nx}
zhg{a>2306:R,s<2598:pmx,R}
bxl{x<2362:A,R}
mvc{s<3498:R,x>1679:R,R}
gpl{m<2634:R,s<567:A,s<637:A,A}
hk{a>3653:R,s<1274:R,A}
svt{s<2591:R,A}
cr{s<3821:R,s<3904:A,m>1221:A,R}
lmx{x<960:jcg,x>1540:A,rdl}
tgc{a>1165:A,a>1119:A,R}
hzv{a<2633:nrp,m<2254:A,mtb}
mh{x<497:cs,gjr}
mzl{s<2381:R,a>2821:R,m<2543:A,A}
hgt{x<184:zqd,md}
glh{x>1889:R,a>3413:A,R}
ks{s<173:cm,x>3166:ndk,a>3185:bgv,R}
zbc{s>2158:ztc,hnc}
kqz{m<539:R,m<607:A,kt}
vgh{a<2446:fb,s<1159:gbh,m<351:jsg,jvh}
lz{m>2276:gz,x<2308:zc,A}
kjp{s<185:R,s>249:A,a<1312:R,R}
nl{m>1476:mt,m<1438:A,m<1456:xvq,gqs}
tfv{m<3121:vf,vsd}
snb{s<1516:R,x>2348:A,A}
gfc{m>2600:cdq,hdn}
vg{x>3062:vfd,R}
khl{x>111:R,A}
vjx{a<507:qnf,a<542:hc,pd}
bfx{a>227:R,x>2544:A,R}
txc{s<1832:A,A}
nh{s>359:A,R}
jvh{m<499:R,s<1619:rfz,m>586:A,jqn}
flb{m<197:ths,x>1530:A,A}
gdd{m<3123:jth,a<1486:bm,m>3629:nnr,R}
cb{m<2205:A,s>2947:A,x<2946:A,R}
knv{s>460:rmr,s<204:db,kpz}
gz{x<2234:R,a<3234:R,m>2551:A,R}
fk{s<1780:A,x<3176:ntf,mx}
jsl{m>91:R,A}
lhg{x<542:R,mgx}
cdq{s<2561:sv,x<2407:tfv,m>3422:rbc,tk}
hd{m<527:A,a>1555:A,m<570:A,R}
zd{s<2479:A,a>2399:R,x<221:khl,cf}
bfm{x>2577:R,a>160:zld,m>1463:dvq,A}
rb{x<914:A,A}
bt{a>1132:R,A}
jrs{x<2873:sp,x<3437:ct,kjp}
grt{s<944:A,R}
hgd{m>2518:gvv,s<1189:R,x>161:A,R}
mkr{m>2473:A,A}
tkm{m>1174:R,x>983:A,m>916:A,R}
bn{s>2765:R,x<3188:A,a>1886:R,A}
sn{s>2977:R,m<1353:R,a<1145:R,R}
zkq{x>827:sc,s>2011:R,zg}
dlz{s<3460:lk,m>1650:vkd,m<1637:A,R}
vn{a<973:R,m<863:R,A}
dd{a<1653:rf,s<1058:rlh,a>2066:dq,zn}
hkg{x>3348:R,m>1480:A,s<1604:A,R}
cgc{a>1202:vns,pc}
nr{x<3136:R,R}
rd{m>268:A,R}
knn{m>1188:R,R}
thx{a>801:A,s<3692:A,R}
ct{m<3225:R,a>1447:R,A}
lcp{x<1979:A,bxl}
cd{x<955:sn,m>1161:A,ts}
qmm{m>1037:R,x<471:A,A}
jq{x>3243:A,x<2901:R,A}
tlc{x>978:A,x<797:R,m>1470:R,A}
nks{m<1055:sgh,s>3161:R,m<1112:vzv,jkx}
tz{x<577:tsr,a>424:fqb,trp}
hx{a>271:A,s>1877:R,A}
jhv{m>262:R,m<129:A,R}
sl{s<1018:A,s>1080:A,A}
nn{a<286:A,a<501:A,R}
lxd{a>1568:rvk,hvv}
gq{m>327:A,x<2822:R,A}
pnh{s>1937:R,a<1387:R,R}
thd{s<3459:A,x<2572:R,x>2681:A,R}
qss{s<668:R,a<1169:R,A}
qkr{a>636:mk,dr}
js{x<1832:gcm,bq}
dbj{x<3313:A,a>2887:A,bxj}
csb{x>575:R,R}
jsc{a<443:R,a>692:R,R}
nx{a<3471:R,R}
tzb{a<3307:nxc,a>3740:A,s<680:A,ggq}
lpx{a>338:qmm,s>3154:sjm,m>1112:R,A}
hvv{a>1135:R,m<1473:cpq,ndf}
tpc{a>1381:R,a<875:A,m<3835:R,A}
bj{s>954:A,m<1531:A,R}
tjq{a<1495:hxq,bbk}
cfj{x<2566:A,m<2545:A,A}
sv{s>2132:gdd,x<2024:zkq,x<2991:sjh,rk}
bnl{a>734:R,x<2827:R,A}
cs{a>72:A,x<313:qtz,a>30:R,sj}
nqz{s<2805:xlr,kf}
qkb{m>1165:bfm,x>2997:cgr,mrg}
ptz{x>3324:A,A}
lh{s<712:tc,kj}
rjj{x>3656:A,m<1580:R,m>1604:A,R}
sx{m<2774:R,a<3645:R,A}
bm{a<723:A,s<2372:R,m>3527:A,A}
dbv{m<310:zv,a<2934:ms,m>432:ft,vnl}
gh{m<2428:R,x>947:A,A}
cln{x<2620:R,m>69:pdm,m>41:fs,zxg}
zk{s>3827:R,s>3785:A,s<3766:R,R}
gb{m>387:rfd,s>2214:R,kkr}
jcg{m<226:A,s>2843:A,R}
ssm{x<2632:R,a>1336:A,m>930:R,R}
dfq{m<883:A,A}
htd{x<1452:lq,s>945:pz,s>338:dvm,zj}
dgd{s<2443:R,s<3244:A,A}
fbv{m<405:A,A}
tcl{x<1026:ps,chb}
ctv{s<481:A,a>1472:R,A}
rpt{s>1877:mxk,A}
dq{x<1367:R,A}
pdz{s>3526:knn,fhk}
vx{s<2758:A,m<1595:R,a<2788:R,A}
ljf{a<620:R,x<2536:R,R}
dqq{m>1290:dg,lks}
xnm{a<986:R,m<2514:vcr,cfj}
qdc{x>588:cc,a>282:rzm,s>1530:R,R}
jj{a<387:R,x<1739:R,R}
mk{m<289:fd,mbh}
tm{m<1223:vn,R}
kdh{a<1013:R,m<2882:A,R}
gkc{x<395:zd,s>2719:lhg,a>2285:zbc,mkf}
hnn{x<1777:R,R}
hl{x>2589:dnq,qss}
fhl{a>420:A,x<1150:A,A}
vgm{a>2672:R,s>3353:R,a>2603:mj,R}
zqd{s>480:R,R}
tsg{s>2554:fvz,s<2051:qp,qf}
tr{s<1278:R,a<1592:A,A}
gvv{x<213:A,A}
dfd{s<2095:A,m<534:A,a<309:gm,zqx}
cdz{s<3302:A,a<1859:ffl,s<3736:R,zk}
cc{s>1964:R,m<141:R,a>408:A,A}
ts{m>927:A,A}
bvd{m>505:A,x>2716:R,m<486:A,R}
hdr{a<1093:R,R}
njq{x>3067:R,x>2637:A,A}
knl{s>3100:R,A}
tsr{x>370:lpx,ss}
ffn{m<1049:tjq,lxd}
jkx{a>3321:A,R}
kpz{m>1082:xhf,R}
kmr{x>2008:A,m>1315:R,a>764:A,A}
lgt{x>2913:ff,A}
fqf{m<1352:R,R}
sr{a<2813:knl,nks}
vnl{x>3082:rpt,x<2811:gb,hp}
rjk{m>503:A,m>349:R,a<3416:A,R}
zh{x>3302:A,m>836:R,x<2687:R,A}
ztr{m<882:R,s<2507:R,A}
fc{s>610:R,s<538:A,m<2744:R,A}
jxr{s>2048:R,a>1137:A,x>849:rfv,txc}
dxs{m<297:R,s<2094:R,A}
fcf{x>1773:R,R}
pch{s>2642:A,x<2100:A,A}
cdk{a<3298:R,A}
lkn{a<3768:A,R}
fs{s<2402:R,x>3363:R,A}
ttg{m>3204:R,A}
hvz{m<2962:mkr,x>263:R,sb}
tx{m<1361:R,m<1512:A,A}
jvn{s>818:hnb,s>485:A,A}
rt{a>2641:dfs,sgg}
rdl{x>1277:A,s>2951:A,A}
qxp{s<2413:R,s>3444:A,m<772:A,R}
ptx{s<2311:R,m>164:fh,a<445:jsl,A}
xns{m<1626:R,A}
kg{s>3805:A,m<1562:A,A}
qh{a<238:A,a<495:A,R}
trp{x>1075:pkh,a<296:xx,s>3050:zcg,sgv}
bsk{s>3042:rx,tx}
ld{s>2496:cdk,a>3476:lcp,a<3222:prh,kfb}
rs{s>1580:R,a<788:A,R}
dmk{m>227:A,a>3007:A,a<2920:A,A}
ch{s>2766:A,R}
lj{s>3677:R,m<1072:R,x<769:A,R}
jlj{x>2487:R,x>2004:A,s>3010:A,A}
glt{m<989:A,m<1136:R,R}

{x=530,m=634,a=3725,s=1229}
{x=1307,m=43,a=464,s=2708}
{x=918,m=57,a=1846,s=794}
{x=2072,m=1258,a=340,s=232}
{x=39,m=1043,a=3007,s=315}
{x=1945,m=979,a=1098,s=2262}
{x=1607,m=1209,a=650,s=258}
{x=3098,m=1600,a=204,s=1876}
{x=2232,m=252,a=2734,s=66}
{x=680,m=68,a=3699,s=1029}
{x=547,m=33,a=472,s=218}
{x=1546,m=910,a=96,s=666}
{x=484,m=391,a=57,s=2654}
{x=906,m=93,a=296,s=2372}
{x=1407,m=420,a=2307,s=591}
{x=1668,m=511,a=308,s=147}
{x=1290,m=991,a=92,s=495}
{x=1876,m=141,a=909,s=706}
{x=999,m=1579,a=1131,s=597}
{x=86,m=1845,a=245,s=1534}
{x=309,m=2511,a=2002,s=73}
{x=2879,m=1283,a=395,s=207}
{x=20,m=1116,a=393,s=100}
{x=173,m=143,a=451,s=121}
{x=1852,m=2969,a=42,s=873}
{x=5,m=205,a=328,s=322}
{x=1020,m=1302,a=1466,s=3630}
{x=850,m=1855,a=912,s=249}
{x=298,m=2764,a=868,s=1005}
{x=1971,m=965,a=3494,s=256}
{x=329,m=7,a=209,s=180}
{x=1924,m=1103,a=600,s=72}
{x=980,m=15,a=36,s=7}
{x=2967,m=507,a=175,s=2028}
{x=99,m=746,a=747,s=82}
{x=809,m=1418,a=542,s=10}
{x=51,m=967,a=207,s=39}
{x=12,m=771,a=401,s=7}
{x=52,m=871,a=797,s=2231}
{x=295,m=23,a=1660,s=178}
{x=2666,m=419,a=274,s=1981}
{x=51,m=1958,a=1571,s=964}
{x=2064,m=728,a=880,s=610}
{x=872,m=908,a=98,s=72}
{x=2460,m=44,a=668,s=570}
{x=432,m=1450,a=155,s=539}
{x=328,m=2010,a=335,s=3590}
{x=2877,m=55,a=8,s=981}
{x=961,m=350,a=347,s=158}
{x=1858,m=1047,a=147,s=887}
{x=1147,m=11,a=285,s=755}
{x=745,m=1515,a=2602,s=29}
{x=132,m=803,a=1309,s=315}
{x=1230,m=348,a=326,s=194}
{x=108,m=88,a=718,s=1950}
{x=665,m=3229,a=219,s=15}
{x=147,m=1011,a=920,s=2186}
{x=2562,m=47,a=120,s=1516}
{x=1755,m=726,a=309,s=10}
{x=2588,m=250,a=2080,s=1115}
{x=456,m=1563,a=1048,s=1330}
{x=2125,m=1158,a=54,s=3246}
{x=2258,m=2098,a=456,s=1574}
{x=2059,m=455,a=650,s=850}
{x=1495,m=430,a=7,s=1117}
{x=450,m=2006,a=1602,s=1584}
{x=1273,m=518,a=137,s=877}
{x=1445,m=151,a=291,s=3292}
{x=1806,m=277,a=603,s=934}
{x=908,m=1031,a=2024,s=532}
{x=791,m=1119,a=1542,s=414}
{x=129,m=1478,a=1207,s=195}
{x=194,m=306,a=578,s=2951}
{x=2724,m=1503,a=344,s=2470}
{x=1369,m=529,a=628,s=946}
{x=2319,m=215,a=772,s=457}
{x=779,m=1420,a=1988,s=43}
{x=1937,m=1475,a=519,s=266}
{x=127,m=25,a=1024,s=1434}
{x=520,m=581,a=287,s=253}
{x=497,m=812,a=839,s=3168}
{x=2540,m=53,a=1854,s=169}
{x=2088,m=81,a=975,s=413}
{x=1165,m=170,a=571,s=633}
{x=139,m=1145,a=895,s=1467}
{x=2222,m=116,a=314,s=1498}
{x=368,m=3240,a=697,s=3743}
{x=376,m=225,a=2580,s=267}
{x=983,m=1528,a=1852,s=184}
{x=1133,m=1164,a=1061,s=9}
{x=199,m=273,a=1377,s=530}
{x=190,m=694,a=1154,s=580}
{x=2056,m=68,a=399,s=203}
{x=3105,m=189,a=1548,s=18}
{x=1978,m=3778,a=273,s=290}
{x=135,m=233,a=3110,s=1595}
{x=375,m=600,a=386,s=1319}
{x=1201,m=713,a=663,s=1075}
{x=133,m=3290,a=2403,s=2185}
{x=2622,m=133,a=1350,s=1442}
{x=1043,m=61,a=2504,s=125}
{x=552,m=539,a=555,s=1868}
{x=3,m=808,a=971,s=137}
{x=298,m=258,a=2103,s=685}
{x=1478,m=220,a=1038,s=129}
{x=613,m=1278,a=982,s=676}
{x=56,m=2690,a=1815,s=736}
{x=32,m=789,a=262,s=438}
{x=288,m=247,a=1372,s=1182}
{x=2034,m=656,a=3478,s=1545}
{x=1448,m=1423,a=2697,s=252}
{x=772,m=362,a=3586,s=999}
{x=948,m=240,a=303,s=231}
{x=12,m=875,a=2823,s=234}
{x=1471,m=467,a=57,s=1030}
{x=256,m=321,a=1333,s=859}
{x=548,m=597,a=1662,s=362}
{x=170,m=413,a=1343,s=1836}
{x=2368,m=1003,a=606,s=192}
{x=966,m=1658,a=761,s=102}
{x=1325,m=213,a=279,s=307}
{x=67,m=598,a=174,s=914}
{x=1412,m=195,a=1625,s=310}
{x=59,m=1293,a=1923,s=175}
{x=2360,m=215,a=2406,s=34}
{x=126,m=10,a=3527,s=1321}
{x=203,m=888,a=1010,s=1332}
{x=3226,m=1128,a=183,s=1433}
{x=263,m=1027,a=1357,s=1639}
{x=1329,m=1322,a=413,s=509}
{x=478,m=67,a=2458,s=1}
{x=2956,m=2169,a=184,s=46}
{x=2641,m=978,a=2096,s=1218}
{x=3687,m=1057,a=1188,s=536}
{x=303,m=22,a=677,s=2911}
{x=602,m=3087,a=367,s=6}
{x=2080,m=137,a=3747,s=1459}
{x=633,m=140,a=951,s=48}
{x=60,m=3698,a=606,s=2175}
{x=844,m=1667,a=2059,s=873}
{x=1279,m=2272,a=1375,s=400}
{x=304,m=30,a=717,s=462}
{x=14,m=2114,a=572,s=1561}
{x=41,m=265,a=17,s=112}
{x=1221,m=49,a=986,s=1581}
{x=1611,m=2847,a=497,s=284}
{x=553,m=1194,a=18,s=471}
{x=520,m=829,a=874,s=1155}
{x=2327,m=616,a=201,s=109}
{x=673,m=1222,a=874,s=307}
{x=342,m=1172,a=248,s=956}
{x=1226,m=1501,a=575,s=306}
{x=46,m=1858,a=73,s=2525}
{x=40,m=2524,a=1575,s=101}
{x=320,m=265,a=1267,s=2708}
{x=890,m=1211,a=67,s=747}
{x=813,m=1151,a=462,s=445}
{x=2549,m=341,a=2896,s=1125}
{x=408,m=4,a=824,s=909}
{x=25,m=90,a=94,s=75}
{x=148,m=1724,a=2425,s=333}
{x=42,m=9,a=585,s=688}
{x=297,m=155,a=1001,s=1571}
{x=2636,m=894,a=62,s=1171}
{x=2637,m=32,a=60,s=2589}
{x=185,m=2404,a=272,s=686}
{x=2671,m=1258,a=292,s=115}
{x=326,m=508,a=1588,s=1915}
{x=413,m=983,a=615,s=284}
{x=226,m=2098,a=151,s=288}
{x=1497,m=2339,a=735,s=1683}
{x=690,m=2040,a=1403,s=222}
{x=684,m=789,a=1206,s=905}
{x=18,m=35,a=1427,s=290}
{x=678,m=69,a=194,s=979}
{x=541,m=2546,a=1342,s=69}
{x=828,m=558,a=2693,s=946}
{x=577,m=181,a=3819,s=2663}
{x=284,m=2466,a=397,s=34}
{x=507,m=969,a=2119,s=2010}
{x=3027,m=685,a=1904,s=1763}
{x=781,m=1942,a=1460,s=1737}
{x=285,m=2008,a=791,s=1821}
{x=1710,m=1446,a=1415,s=463}
{x=637,m=843,a=67,s=999}
{x=679,m=1982,a=869,s=135}
{x=324,m=1489,a=897,s=1650}
{x=2654,m=943,a=600,s=2739}
{x=1150,m=2385,a=451,s=3120}
{x=2151,m=658,a=2098,s=1254}
{x=3225,m=686,a=645,s=993}
{x=91,m=967,a=324,s=2513}
{x=541,m=349,a=2674,s=1663}
{x=152,m=859,a=2227,s=575}
{x=1850,m=372,a=1309,s=52}
{x=1483,m=1990,a=499,s=68}
{x=1885,m=2916,a=15,s=874}
{x=2606,m=2212,a=67,s=492}
{x=971,m=2447,a=638,s=2378}
{x=870,m=301,a=1403,s=172}
"""#
)

