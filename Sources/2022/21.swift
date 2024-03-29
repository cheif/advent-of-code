import Shared

public func day21() {
//    print(part1(input: input))
    print(part2(input: input))
    // 5973215931858 is too high
}

private func part1(input: String) -> Int {
    let monkeys = Dictionary(uniqueKeysWithValues: input.split(whereSeparator: \.isNewline)
        .map {
            let split = $0.split(separator: ": ")
            return (split[0], Job(string: split[1]))
        })
    return monkeys["root"]!.calculate(with: monkeys)!
}

private func part2(input: String) -> Int {
    var monkeys = Dictionary(uniqueKeysWithValues: input.split(whereSeparator: \.isNewline)
        .map {
            let split = $0.split(separator: ": ")
            return (split[0], Job(string: split[1]))
        })
    monkeys.removeValue(forKey: "humn")
    monkeys["root"] = monkeys["root"]!.changeOperator(to: .equal)
    while monkeys["root"]!.allRefs.count > 1 {
        for (name, job) in monkeys {
            if let value = job.calculate(with: monkeys) {
                monkeys[name] = .number(value)
            } else {
                monkeys[name] = job.resolve(with: monkeys)
            }
        }
//        break
    }
//    for monkey in monkeys {
//        print(monkey)
//        print(monkey.value.isUnresolved)
//    }
    var reduced = monkeys["root"]!
    var result: Int?
    while true {
        print(reduced)
        reduced = reduce(job: reduced)
        if case .calculate(.ref("humn"), .equal, .other(.number(let value))) = reduced {
            result = value
            break
        }
    }
    print(reduced)
    print(monkeys["root"]!)

    // Sanity check
    print(monkeys["root"]!.resolve(with: ["humn": .number(result!)]))
    return result!
}

private func reduce(job: Job) -> Job {
    switch job {
    case .calculate(let lhs, .equal, let rhs):
        if let (new, inverse) = lhs.inverse() {
            return .calculate(new, .equal, inverse(rhs)).resolve(with: [:])
        } else if let (new, inverse) = rhs.inverse() {
            return .calculate(inverse(lhs), .equal, new).resolve(with: [:])

        } else {
            return job
        }
    default:
        return job
    }
}

private extension Job.RefOrNumber {
    func inverse() -> (Self, (Self) -> Self)? {
        switch self {
        case .other(.calculate(let lhs, let op, let rhs)):
            let keepLhs = lhs.allRefs.count == 1
            switch op {
            case .plus:
                return (
                    keepLhs ? lhs : rhs,
                    { .other(.calculate($0, .minus, keepLhs ? rhs : lhs)) }
                )
            case .minus:
                return (
                    keepLhs ? lhs : rhs,
                    { .other(keepLhs ?
                                .calculate($0, .plus, rhs) :
                                .calculate(lhs, .minus, $0)
                    )}
                )
            case .multiply:
                return (keepLhs ? lhs : rhs, { .other(.calculate($0, .divide, keepLhs ? rhs : lhs)) })
            case .divide:
                return (
                    keepLhs ? lhs : rhs,
                    { .other(keepLhs ?
                                .calculate($0, .multiply, rhs) :
                                .calculate(lhs, .divide, $0)
                    )}
                )
            case .equal:
                return nil
            }
        default:
            return nil
        }
    }
}

private extension Job {
    func calculate(with monkeys: [Substring: Job]) -> Int? {
        switch self {
        case .number(let value):
            return value
        case .calculate(let lhs, let op, let rhs):
            if let lhs = lhs.value(with: monkeys),
               let rhs = rhs.value(with: monkeys) {
                return op.run(lhs: lhs, rhs: rhs)
            } else {
                return nil
            }
        }
    }

    func resolve(with monkeys: [Substring: Job]) -> Self {
        if let value = calculate(with: monkeys) {
            return .number(value)
        }
        switch self {
        case .calculate(let lhs, let op, let rhs):
            return .calculate(lhs.resolve(with: monkeys), op, rhs.resolve(with: monkeys))
        case .number(let value):
            return .number(value)
        }
    }
}

private extension Job.Op {
    func run(lhs: Int, rhs: Int) -> Int? {
        switch (self) {
        case .plus: return lhs + rhs
        case .minus: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide: return lhs / rhs
        case .equal: return nil
        }
    }
}

private extension Job.RefOrNumber {
    func value(with monkeys: [Substring: Job]) -> Int? {
        switch self {
        case .ref(let name):
            return monkeys[name]?.calculate(with: monkeys)
        case .other(let job):
            return job.calculate(with: monkeys)
        }
    }

    func resolve(with monkeys: [Substring: Job]) -> Self {
        switch self {
        case .other(let job):
            return .other(job.resolve(with: monkeys))
        case .ref(let ref):
            return monkeys[ref].map { .other($0) } ?? self
        }
    }
}

private indirect enum Job: CustomDebugStringConvertible {
    case number(Int)
    case calculate(RefOrNumber, Op, RefOrNumber)

    enum RefOrNumber: CustomDebugStringConvertible {
        case ref(Substring)
        case other(Job)

        var allRefs: Set<Substring> {
            switch self {
            case .ref(let ref):
                return Set([ref])
            case .other(let job):
                return job.allRefs
            }
        }

        var debugDescription: String {
            switch self {
            case .ref(let name):
                return String(name)
            case .other(let job):
                return job.debugDescription
            }
        }
    }

    enum Op: String {
        case plus = "+"
        case minus = "-"
        case multiply = "*"
        case divide = "/"
        case equal = "="
    }

    var debugDescription: String {
        switch self {
        case .number(let value):
            return "\(value)"
        case .calculate(let lhs, let op, let rhs):
            return "(\(lhs) \(op.rawValue) \(rhs))"
        }
    }

    init(string: Substring) {
        if let value = Int(string) {
            self = .number(value)
        } else {
            let parts = string.split(whereSeparator: \.isWhitespace)
            self = .calculate(.ref(parts[0]), Op(rawValue: String(parts[1]))!, .ref(parts[2]))
        }
    }

    var isUnresolved: Bool {
        !self.allRefs.isEmpty
    }

    var allRefs: Set<Substring> {
        switch self {
        case .calculate(let lhs, _, let rhs):
            return lhs.allRefs.union(rhs.allRefs)
        case .number:
            return Set()
        }
    }

    func changeOperator(to new: Op) -> Self {
        switch self {
        case .calculate(let lhs, _, let rhs):
            return .calculate(lhs, new, rhs)
        case .number:
            fatalError()
        }
    }
}

private let test = """
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
"""

private let input = """
jwql: tqsm * svnj
dbzh: 5
gnsg: cscc * mpjs
zmrg: tscm * nscs
mdgm: 2
pbrd: 2
zlcn: zvnj * mrrb
blml: 9
rdsl: dgcp * vhfh
lsth: sbjp * cwzv
whth: mdgm * sjgn
clcj: pcms * blml
jqvn: 7
tfvn: 5
jzbv: 4
qvgc: 3
npqm: 2
ljqw: 2
lddv: pfqq / vpsr
hlcp: rmjw * dfsr
hfss: 14
rzwz: 2
jsrs: vqzw - mrfv
smbr: ltrm - nsrr
qpth: hmgv * wjpp
vhfh: jsms * wqrt
nwqn: 5
fvmv: 13
vcfh: fbtw + djcj
swzm: 2
wvwf: 4
fbcc: 7
qgtn: 14
tlqm: pnvf + gsdr
mpqs: 14
rmhj: 2
vznw: zhvz * lhcr
rvlm: phps - hbcq
dnvd: 3
ldvj: rjld * zrwh
zcpc: fgdw + vvqq
fjwb: 2
mfqc: 20
jrgn: szvz * jzbv
mdgl: 4
pcch: vmmw * mrcm
pscr: 15
llpb: crlj * jfnp
zjgt: 10
nmmz: 1
rdmc: 8
tpmz: wnms * ztnq
sbwb: 4
jpdw: 2
mstb: mvrp * mqhl
gmsj: rzfz + thnb
flnj: 5
bpjm: 3
jdqq: 9
mnrl: wjzg / rdmc
tdnb: 3
hhgt: 2
gjdq: qgfq * nmzt
ndrd: 2
mspz: npbq * qsfj
jqvz: 3
mrst: vjqw + dbpv
lljn: 2
swjc: 3
jwph: 11
djqp: 8
rpcj: vrlf * qppr
llbw: nqwl + pljj
nddv: 2
qsgv: vzft * gczl
psfs: lvdf - mmlw
ccft: mdrn * mstb
lfvh: brjc * dndb
czgl: 3
wzfs: npcm + bfgr
mgzs: 3
tnmz: zztb + jtpw
hqnp: 3
nwbb: mzbv + rvsv
rgjt: 3
rnnq: 2
wdll: wlvl * rfdf
gldc: 4
chzd: qpqn / zmfn
hsnn: 4
wtcd: 3
hfzr: 8
zclt: gffg * gvpn
nctf: 7
jmvc: 5
rmfw: tgrf + lsnc
vvwr: 4
cwpc: dvlb * dctl
fwzt: jgpd * rftp
tznf: sglm * jsqw
tfwm: 2
jmqz: 2
crcz: vwpc * lsrv
jpsb: 2
jnqm: qqtc * hlzd
qgrs: pnbb + tfvn
bbhz: 4
qwqw: pgdm + rvfr
bpfl: smbd + jrrq
jlbh: flgh + qqbd
tsnv: 2
vpsr: 2
cttg: lfgc * bbhz
tjcm: 4
pgph: nmzl * jzhw
cntc: gwpn * qmjn
tgch: 6
zjdz: 4
sjch: 4
tdqn: dphb / rmhj
hbtr: 2
jphc: 3
bwhb: drft + nptq
zvvw: 3
lwdc: trzp + wzfd
zmbb: 4
rhgq: 3
hzpg: 4
smbd: 3
hhbj: 10
psdb: gfsh + wtwv
ltng: whcv * hqch
gnfz: 11
hzwg: jsvd * cbdg
cbdg: gzmv * qdtj
gljf: 3
pnbb: 2
dlcz: 11
tzmm: 3
lhjp: 2
cnlm: ztgr * mqst
gcjd: 3
gbgw: czqs * wzsn
sqsc: 1
dqbq: thth * zptv
dvrd: 8
dnhs: nvmr + ggfm
hprc: 1
stls: 3
mgsz: rjhl + fhvc
swth: mgzc * mccr
ndzf: rwwf + lfdb
lszf: psdm * hhds
pwtz: jmqz * zwdd
tnhm: ggll + hpmd
tdhr: 5
mqrv: rwqw * vdbq
grrb: 3
hfdq: wwmq + gqlq
wgmn: 10
trzp: fqhp * tcpf
vblr: 5
mflt: 2
gvcr: 2
rvrp: 6
pdpj: 3
rfmr: 7
trcg: 5
vwcc: 4
mdlr: 3
flwl: 2
rzfd: 8
zlbd: jpgp + mzmr
ccnp: wqlf * pqmw
cdgd: 3
cggc: wsfs + rpdf
pczj: jgmg * bcmd
dvww: 5
zngh: ndbs * dczh
wrlp: pgts * jpsb
bvrn: 5
dtnc: gdrl + lsdf
fdhc: pwrg * ppwg
hpdd: 2
fwln: 4
jtbj: dtdj * vsqt
wdqq: 4
wjsq: jldj - cglz
djlm: 2
vjqw: nfnw * wjlh
ggvc: bvvc * grws
wbft: ccnp + wsbv
tsvq: nqjg + qbbv
snwb: wdwp + pdbf
rpdf: fzwr + fhrb
vgzr: 2
zhvz: mcbj * dmmh
cpvn: 5
rprh: 3
qdtj: 2
sdcr: lhfl + twrb
cswv: 1
dnbq: wwzp + wdnv
zrpj: 2
cgtg: 17
jstb: 5
hwmg: wmmt + vwff
rbmm: 11
hfbv: 5
hcsr: 2
gczl: 2
flbp: lsbq * wzdf
cqzm: 14
hgfg: blqj * glws
vqwv: 2
djfh: 5
rnnm: 4
ppwp: 3
bpgc: mftz + dfrl
lzwp: mqzg + bcdg
dphc: bjpr + qmdr
sbcl: 2
swcn: nrpj + vvhd
ntqn: vthq + zfsf
sflq: 4
pfbd: 8
mwwf: 2
bzzl: dpcf + smjj
tnmv: 2
sszs: 2
vfmv: dbqw * bgjf
hlzd: 5
gnpz: 2
sgcv: 4
rgtd: pgzn - mfzn
gttj: 3
wwmq: gchw + pqhs
hpzr: prwg * jdwq
tdvg: wqch + bnmr
pwrg: cbsm - cdhh
qmvv: wbrr + lpmb
tjmg: qdzq / wfjf
zclc: ljng + gmsj
tqwl: 5
szwd: btpg * swtj
nmjq: htww * dwpw
ccqq: 2
mnqc: qzrj * tsnv
pdcc: 2
fzzt: cwnw * wdvh
fbnq: 1
fsdw: 3
qlcr: qcst * ctgg
qjcz: 2
ntfg: 2
hvsg: mgzs * nwbb
ncrb: ljtw + wclb
nwgd: qqdj * fssq
qbrz: szgs - thjb
wvsc: nmjq + twql
dmbl: bvpf + zdbl
dbqq: 2
grln: 2
hzpt: hsfn + smvj
mbnh: 13
cjvq: 2
ptbt: hpdz / qtwd
cncc: 10
qgld: 1
csgw: 3
snlv: 7
nshb: qvmg * ccft
tmhr: 6
dtlj: 9
wzsh: dfld * nlzv
thrm: 4
szgv: qdbz - tzsp
qpqs: 12
rcqf: bwdg * mhmw
zddm: mhtm - fjzq
rjhl: vqgm * qnnl
rvfp: bqbb * jgrd
mjqq: fbcc * zbnw
dfjl: wfwm + dhsh
cnrj: 2
nmpt: vtzc - ffbd
hgvw: qnww * slhm
cghj: vnrr * ttrc
nmzt: 5
bmsc: btbr * hmrb
dprf: lbht + bvtd
hpfr: 11
svnj: 2
fppg: cqzm + hlqb
pccp: 17
nmgl: 5
chnh: 4
hmwf: bfqz * bvwp
tmpv: 9
jfnp: ljlj + htvj
vfrz: 3
llzl: tdqn * swzm
wjhg: fgbg + mtmt
rljp: 5
fdjr: ddtt * pdmm
jgvd: mflt * prsr
jpgp: gzsv + tvrh
tlsr: 3
wpln: 2
rvsv: htbd * fmpg
mfdj: ljjb + ppzf
zchq: 5
dpgj: sqpd * qqjr
wvdg: dwnf * jdbd
tgfs: 2
rbvm: fdvb * zfpr
jsvd: jrgn + bwts
fcns: hfzr * rljp
bwll: 3
cpfw: 2
mqqh: 3
dgcp: 7
sfvg: zrvq * stfm
nfzh: ppvm * bhlr
bqvr: 20
bhvl: 7
twnp: 2
wjpp: gmld + pggp
dwpw: 2
ndfj: rhnv * nqhd
gczg: 1
pthm: rvbn * ppld
lwgd: 3
gdsq: qwwl - jzth
bjzb: mstr * mslc
gtjc: twnp * hgwg
wcps: 13
sbqt: cnfh * cdnl
gflq: 5
wvfr: 6
fqbn: nsmv + jnqw
qdjt: 5
blpr: 3
bnnw: dccl + fmnd
mrmz: 8
dnjl: lnwm * jqdc
hnbl: tlnz - nqvl
bnmd: 3
hchd: 20
gsbn: mdcf * ldch
whzz: 2
hpdl: gjzt * rzfd
pdvp: 14
cvjl: 11
hmdt: 3
ntqj: 4
mnjr: svvl + cwdv
qpwh: 5
lmcn: 5
hfmg: zvdj * tgcc
wvtc: nrcs + jwcv
cqdw: cvld + wdjq
qtwd: lcst * zrmr
wdqw: 7
lhpt: gqvv * dfnh
rllb: 5
lrpc: 9
fqjw: cdmb * cswj
bcvc: 3
lthz: zqwp + qwjp
vdmn: 4
bgjf: 5
bhfc: 6
fwgr: 2
vjmr: bclh + tncl
vpcl: tbrs * ssvr
zlsb: 6
bmcp: cmgl * mdqs
fmfm: 7
fmnd: hnhs + cbpw
lzzq: 5
ltsr: 5
bcdg: 2
rjwd: 5
qbnw: dpmq + mqzv
rfmq: 2
rdpq: wnfd - stvc
chbq: fzzt - vznw
jcbp: hdpr * swpr
vbqp: 2
tprf: 11
vvgt: bjrl + mrmz
nrdn: nmgl * cdvg
rdmt: chmf * tmgq
jvpl: dlrc + szgd
dmnv: wcbw + sjcb
ptjj: jlpb * prqv
zlbp: nqvv * dmnv
trcd: mqbd * wlpf
rdgb: pjlg + twpb
mtmt: 3
wqlf: 14
rzvt: wttp * ssqc
tlbn: tbqg + rswm
tffd: 2
jdvb: 14
vthq: 1
fghp: 4
dzgp: 19
swcp: 2
hmgv: 2
lzlp: nqbp * vlft
wjtp: lhwn + wvtm
qznj: wzbm * zlcn
jnhj: 2
fwhh: 7
mftz: fcsr * jfrp
wjpt: dfjl + zppz
phvl: ttzn + swcp
qdrm: qsjh * llzj
grmr: jqnh - qsjc
dnpj: 2
cvfz: 7
nrdc: 3
ftvs: 5
qnww: hfss + rhcs
fhhh: fhbb - brvb
npcm: 5
ddzr: 2
przn: ptff + trrt
rtvg: 3
tlfp: qbrz * vtmm
vwpc: pwsg - lzfd
chvf: vmhp + pdbl
vbmg: 11
lcst: 2
jpdg: fwhh * tdlv
hrpz: zhtq + rjwv
rnhr: 4
tbwd: bjln + ftbp
qmhg: ptgb - bhfc
mbqg: 1
jcdn: djqn - hfcl
mzzl: 2
tbwj: 2
wgmh: 3
qfsr: 3
lqlp: 2
slqs: 2
wzmm: 3
dlmj: 2
psrr: 18
mtns: cvvp / nwrq
tfsd: 2
whml: tdpd / trcg
bvmd: 4
rrtr: 2
bmds: 6
wrdh: lbhd + rnrz
fdvb: 4
pmlq: zbjj / hfpr
pbps: 3
lmvq: 4
zsrv: rtmt + gdsr
bdlp: 9
zqgl: gcsn * fdhl
ljlj: 9
zshc: 2
chdw: 6
pngf: 2
nplz: 4
fwlr: cggg - stls
wrqg: jzpn + wqqc
grsv: szvt + rwgf
gtzp: ldjd * tfrq
ngfn: bzqc * tprf
bgws: fgcf * vlgv
qnpz: pthm - lpwc
tpgv: jqcr * tzpw
mdfl: 5
rwfc: tdbn + cswv
rwlb: ntzv * tzdq
lcmm: cdtl * sgst
hspt: rllb + rnqw
bwdz: 4
mmdc: qvbm * zddm
zbcw: 4
jgzl: 3
dpdn: 2
mjzn: jssm * twtg
tgcc: 2
mzmr: lfgv / hsdq
mwvg: 3
nfcq: 6
snsc: 8
lsvd: 4
wwgw: 3
nwrq: 2
tmmf: 3
gffr: 5
tdpd: hjbt * tfsn
vfrn: 4
jldj: bmnl * dfjn
jgsn: 2
qmvl: djfh * nqmh
mcnj: 5
rcgh: 4
pccf: 2
rchv: 4
pvqn: 3
trfc: 3
prsn: 7
npwc: gtjc / bjfm
qtrb: 5
ldcn: 16
hlqq: nltt * mjnm
dfmb: 2
nwrh: 2
lfcg: mgsz / nddv
jhhj: pqtl + gpcg
hdvf: 2
gwjf: zcsf * flnj
stcd: qpwh * nhzt
nwcz: 19
wqrt: smlh * tqwl
gdsz: 4
nwfv: bcvc + gcjz
hzpn: 7
qbhg: 5
nzjh: lvqb * fwln
lqml: 4
wqmt: 4
ddrl: 2
bhgc: hmfz + qfsg
wrtb: mhhm + hfzt
frzv: trml * mwpn
vjrs: 4
rpsc: jszm + hzpn
rszd: 5
dphb: przn + bjwc
rczm: 1
bqbl: crnl * plnq
dddh: lbhh * wlvr
wjcr: pvdl * rhbs
vntl: 9
jqcr: jsvp - ffjs
szdf: 17
hsfn: 8
wfdv: 2
vsqt: 2
fswf: 2
cmgl: sswb + zsfg
nrrs: dnjl * npqh
jllh: 10
nntm: 1
tgrf: 2
zdpw: sdvv + ggnn
tvrh: djwb * vjvc
ttrc: 15
rmgn: dpbn * jbcb
fsjt: mftn + hgtf
hscb: 9
jgcf: rdcj + tlqm
sfrm: wdpz + jqvn
qsgb: gmrp + jlbh
rbnd: 1
jjjz: 3
rmvz: 6
dbcq: 5
qpdn: qffn + wrsf
nqjg: djfj * zvjq
hnhs: 8
gldq: 3
root: jdqw + nrrs
rfwn: tmhr + sbdb
rdqs: 3
rwqw: fcdw + cdjw
tslc: ghvt + snwb
ffbd: 2
zlpr: 3
rsjw: 2
qmrs: 5
rwqr: 5
bhqd: btsh * mnqc
wlwv: 11
hvsm: qzgh + qjjt
crlj: 2
qphq: 1
rhbs: pqfd + mqrv
hvlg: phvl * ggpb
dgdr: wmrp * pvch
vtqd: 2
dmbw: 3
djqn: sntt * bsrp
twzs: 2
nvff: 8
vwcj: pmlq + ndfj
sblg: ccrb + jshp
mslc: 4
jtdd: wwhs * qrvv
dzvq: 11
mmlw: 12
gmlr: dtww * pdpj
pbdh: 11
wgfc: rssf * zpft
jncn: hchd + hbln
mwpn: 4
lmbf: rpcj + mmmf
svdd: nzbh * wzts
ddmc: 2
zzlf: 2
lbnq: 3
wzdf: tpbw * nlfv
zqwp: 5
vbwq: 3
wgfr: 7
bzqc: 5
wwnj: rzwz * bcvs
nwdj: vcbn / pgjt
bvnq: nmpt + gspb
tjhw: lzwp * wfzs
nbjt: 7
hvtp: 2
nmjj: hrpz / lncq
zgrj: nnvt * pjdp
btbr: 2
cqfp: 7
rhds: jhcr * rmrr
njtt: 4
pgjt: 2
jzhw: 8
hbtb: 14
tflw: hlmj + svww
nnhf: 3
pjhq: dzvq + sstq
mpbg: tztr - npff
wcrj: hhmq / lzqm
cpvd: 10
fjjc: qcjg * jwhr
zlvj: 3
pqhs: 11
gqwq: zqzr * mfgw
mmsr: 4
lzfd: 5
vjvc: 2
fzms: nsbz * vtqd
zhtq: jhhj + qvsc
tjzp: tdhr + hzpt
lzlf: 2
gblg: 16
qnfb: 4
vggh: 2
trml: vvnh + rnsd
blqj: 2
brbv: 3
mzbv: ntfw + gbvr
wppb: wjcr / wgvm
vrqj: 3
bjfm: 2
tpbw: 5
ntfw: 4
gdsr: qqqp * bvzn
shvv: 1
nflt: 11
cqtz: 2
vtbg: jhmj * vdtj
dbqz: jcvd - tppz
pgts: 10
djdw: 3
jppl: hfjm * tfdv
hzhc: srbj * zjdm
zsrg: vggh * njpf
dnmj: stcd + jbhb
jtpg: jmrf * nwmh
rqmw: zmrg + fhpt
dmnh: cnrj * gsfj
jqnh: gfvd - dphc
gjsc: mzfw + bclv
qhpv: lqwt + frjt
pqfd: qwpg * bvgd
chpr: nmpz / cmrm
wvtm: 5
ppld: prpz + sjch
crhs: zlpr * jsqp
hvhj: lsvd + tgsp
hbjc: 7
mmhg: 7
gfmb: wnzg * tbwj
wvlr: mhgb / hrmd
hlsn: lzzq * bswm
wvrm: rjhw * szdf
csfj: 6
gqdg: mdrc + sbfh
gjgw: cjpp + hzcg
vdwr: 3
pnrd: 7
hdjt: 11
qjsz: nlrq * cbrp
twcm: tnhm * hbtr
bswg: 5
thcj: 3
mfdb: hhwh + rpql
sljl: 3
tfdm: 8
jlnj: 19
sgdd: 7
wjzg: ssnq * rbvm
tvlz: 3
bvgd: wdrq * vrtr
hbcq: 1
nghl: 3
frdq: 2
tbhd: tlwm / pczj
gsft: rwwc + llmq
sqrv: 4
gzmv: tchr + dwsw
bfnm: 4
mqqs: bvst * gjdq
hbns: 9
brjc: 7
whcv: czbj * zcvz
qsrh: hcbm * zbmw
fgcp: 10
sctg: 5
ftpg: vrwm + nfjp
qqlr: lzdp + zctw
drqv: 3
zwcs: gvcr + rjwd
djcf: 13
fhzl: 4
rfwp: 3
gdnj: 4
lpwc: wrdh * gdzh
cgnt: 11
hlqb: 12
czhr: gdnl * jtph
vrtr: 2
hjrw: 5
fzgw: tqtg * mdqc
fqhp: 9
smvw: 3
rnqw: nmmz + pjjv
vrwm: 1
bctr: pcvp * jsfb
szvt: 15
gblb: szsh * prsn
zdqz: jjbd * mmsr
ncfz: qzmv + nshb
zzhl: 4
szsj: jhpr + tvnp
dqmj: hggm * cjvq
vvsm: dtlj * mzcr
qgdc: 2
jrzs: clwf - tmsh
fmhr: npvb * ffbt
llcr: pdfq * fvqt
qhvb: 3
nsjg: rznv * dzgp
zbjp: chgv * lcwp
dqvf: 1
bjrl: 3
jwnj: 10
lsnc: dfsh * blhm
qtwt: jcqs * npqm
qzrj: cnpl + qvzf
rtrc: 7
smjj: tldj - fjrw
frrv: 5
qhwt: 4
qvzf: 1
zmnz: 2
pdbf: 19
prgp: 14
dlfn: 5
bqbb: mglh * tmrv
sbjp: 11
lbbb: lsmc + jssw
lvnq: 7
cgnd: 2
jhjh: tpwm * zsdf
chwl: sscm + ltng
pnjv: bffv * gbnd
ljcm: 4
mbtc: 3
slcg: 19
thnb: 7
pzmr: szwd * vcgm
wlpf: bgsz * lphm
ddtt: 5
lgpq: qrrv + psfs
csbn: 4
fccn: pvsc + mjgz
nwvt: 5
mzrj: prml + bvlv
bffv: ztjg + twmw
gphq: fswf * wzws
rhcs: 17
crdq: 3
jbwl: 13
wtjz: 1
gnpd: 3
rbrw: zwbm + dqpr
lmlf: 3
prml: pwld * dnhs
ppwg: 5
hbln: rhvj * lbnq
tmfb: pgpg * bdjw
zhvc: 5
fzpn: gflm * mvsd
wqqc: qsgv + smpc
sbvg: ztql - drlj
zqfs: 3
fmpg: 4
jsms: 3
dpmq: 3
cvgp: lqml + ngfn
wnql: mtpt * nwvt
jcdw: hcmr + bngv
bpfj: tdvg - drhv
dwsw: hczs * rdnw
rjwv: 5
zmlm: 4
gnqp: 3
fvqt: bltq - cvbz
tbwn: 5
grws: 8
zptv: 2
grnh: vcfh * lhjp
sqpd: dhdh + jhjh
vbvf: vnhj * mbgw
cjpp: rgtd * wpln
cgjm: fsjt + tlbn
wvwn: 5
stbv: 12
shpg: bdww + cmpp
qrrv: bccv / jczp
llmq: jsqn * bfnm
mzwg: vrqb + wdnm
rjld: qsrh + qvph
fbbh: gmlr + ntfg
jgpd: 2
pljj: rwlb / swqf
wtcb: 3
wnvb: 3
srbj: 4
tsvp: 5
ztsp: lhfq + mqlc
ntrd: 4
sdqd: dctv * zmnz
vmwv: 2
bdfj: 1
gbqz: nrrh + vjss
qmdq: 1
gsfj: lljn * sjvt
vqdb: zztm + tbwn
rrsb: 2
hzrt: zzrg + wvmm
nwdn: ptsl + scwd
gvjm: shvv + hhzp
sqjj: 2
vtmm: 2
mrfv: 2
qwfc: 4
snbt: 4
mdqc: nwrh * mlcw
mcbj: 2
hfbb: mdlr + djdw
tszl: 3
vljf: pdcc * ztbg
vcvh: 2
fsbd: 1
pqmw: 4
zqqs: 4
gmbg: zngh / vfrn
pjpp: 3
jhjf: bntt * jwph
bfgr: 20
hpwf: 3
gchw: 6
nrsw: 4
zplw: bswg * sgdd
zdbl: 1
nnnz: 2
jqff: 3
qvvn: 2
gndt: wdwr * bmsc
dzzc: jnbr * vvmd
wbrr: 3
pgnd: 3
jddn: ldcj / hfbv
zgvc: 17
dnlc: 10
rftp: 13
nwcr: ndhv + gdfr
fgqw: zswn * jrzc
gvmd: jcsq / ndrd
cwwf: jfpv * csgw
flgh: wgdz * wvtc
mgzc: 20
fhbv: pvpm * pfrc
tqtg: znvj * nvbg
qvph: pjhq * nsbq
ppvm: 17
znzl: 3
hfzt: 11
sdjd: 5
wcbp: tvdc + fngh
zzwg: 13
wmrp: tmpv + fqjw
bfrh: hlht * zrcm
hczs: lswd * gchc
fssq: 2
qsfj: 9
mstr: grmr + gnwc
bgrd: 19
fhqr: 16
cmwh: vvlm * wjtp
cbpw: 3
wdbm: gwcc * qsrf
zbmw: csfj * rhzn
sdmp: 10
jvpg: dsrn + dpgj
szwz: 3
jszm: fmhr + sblg
tssr: mhhf + dgww
cdhb: 2
hcpl: rchv * vszn
plgc: 3
twsc: 3
mzpw: cbgb + csqb
plnq: 5
fghg: lrjz * bcnh
nwqb: czhr + tqrg
cnfh: 3
mftn: zdmp + sbll
lggm: qstn * whdr
gfsh: 17
hzcg: jgzl * cprz
ldcc: 2
vbbl: nnmr + qgmp
lfdb: rsjw * ffzf
qgbl: 3
lndq: gwjf * fbtd
mssp: cgjm * mzgg
fqrh: zrbl - dddh
rdzb: ntcs / wrnp
mjmv: rzvt + bfrv
tjcr: gdsq + gqvp
wzfn: bpqv * zngc
cbgc: pngf * dlqt
wnct: 5
hdpt: 2
fssv: 2
jdgm: 6
ghvt: 5
jnjq: 5
gdcj: 3
jbhb: psww * hdjt
pftj: vrqj * lrjv
ptff: mtns * znpv
prjp: 7
lsmc: 18
fgcf: llpb * rcpw
nzbh: fsdw * pzlb
zbjj: mjqq + hvfr
jrld: 5
qvsc: jcfj + vbwq
bhwv: 7
fhql: rghb * smvw
wfwm: 9
wvcs: qzdf / ctcp
fwtg: 2
jjbm: 4
cwdv: 6
gnwc: glqg * qmjb
njbp: 3
pcbt: mlhs * pndw
qghq: 19
fcdf: mpfd * sdjd
dbpp: qsgb * bfwn
fplw: hphz + lhpt
lmzd: 4
hctp: mbbj + sdcr
dlzm: 4
qsfb: zgvc + llzw
wrfn: 3
nptq: 4
ndhv: 16
fzwr: jtdd / cqtz
cvld: 3
jcfj: fmnv * nhtd
tlnz: cvdp * shcz
rcrv: gcjd * fmds
mglh: 4
nzhv: 2
zrvn: prvz * wvwh
ldjd: 2
bwdg: 2
qccb: 3
fbtd: 2
sjrj: hcsn - vbbl
thth: lpfg * tttq
rvqw: 5
zrvq: 10
zqsq: cvfz * dngr
lcwp: 3
dfsh: 3
pgnh: 5
csgs: 4
cwht: wwvv + mqnf
ldnh: svfq + nmjh
dczh: 2
bmdc: 8
bfnc: cwvm + jtwm
bngv: 12
bgrl: vfmb + jrnr
hdnn: 2
gcsn: 7
ttsh: 1
pbzw: 4
qzgh: gfzs * dbzh
bhlr: 2
pctv: 12
jlpb: rnlj * djcf
gwrb: tbrw * wbqs
tmcp: tjmg - zgqm
qrwj: tzcn * cwff
tqdc: 3
vhns: qgbp - hvqz
pfph: 3
pvqq: 6
swng: 2
cdvg: 2
ctgg: 3
rvfr: 3
vscz: 1
tfpc: 1
jpdt: dmcb * mfjv
fgcz: 13
hcbm: wzjb * pfsv
mjrf: sjrj + chsw
fbvd: twzm + sqrv
hhzp: zbhz * vdwr
qdhs: pgph / pcmd
chbn: tpgv / hzhr
nnqd: grnh + ttff
qhvt: 2
grgs: jqdw * dftz
zhlb: 3
fbbj: jnqr + rcqf
btsh: 2
smvj: hdpt * qdcn
dfrl: hmwf + mmlh
wjtd: zwhd * lhcg
sdvv: zgtr / qgdc
fppn: 2
szlw: 2
lrsm: 18
cwnw: sdwr + qdhs
mdqs: 2
bvpf: 14
jshj: 2
zthq: hwbw * lqht
lqjf: 5
lqwt: gqgj * vbdd
nfzd: 2
qcst: tdcc + mqrc
qlrf: 3
lzvn: 5
gqqr: brlz * hbjc
vhbl: qfsr * cfch
jppq: 2
htww: 3
vbsv: 16
bcvs: jsqt + cpjn
gvht: czqn * nrdv
mqbf: gqqr + zpsb
qlbs: 5
sbfh: qpwv - zjps
wdnv: 5
wvwh: 4
cscc: 5
hglp: 2
ntzv: 14
vtzc: npnv * dvww
chgv: 3
twrb: 7
plgj: 8
pzlb: fgcz + flwb
mlrb: ldgh + vhrc
hcnv: mmcp * glmd
hggm: dgsn + gsqp
rwwf: dphh * hlqq
jlvt: 2
mfdn: rcdh + qznj
hrvv: vfzt / zlfm
czqn: 5
pvpm: hvtp * mnqf
bntt: 4
ftqp: 6
mqbd: mhgd * tgvg
vrjq: 5
zwhd: 3
fbrs: 3
szgs: hpbc + zcpc
trzt: 5
dqpr: jcdn * zrqw
czqs: wgmh * wjbf
qsjc: vbth * djlm
gbrr: 11
tppz: 6
gzww: wnql * zszf
bbjq: 3
qrgw: wfbz * gqpp
dbqw: 5
dttn: 4
qlst: vljf * jqvz
wvml: 6
bdvv: 5
frlb: 5
ptgb: hspt * qccb
qwvl: wvfr + fwlb
bbnq: 5
mqst: 13
tbdp: lscw + zchq
vbdd: hqnr + sdpr
qqwg: ldcn + jpzq
mbbj: rshj * llvf
qgnj: 3
mdcb: mpqs * gdqd
ctth: 3
zvdj: qcsg - fgcp
tzdq: gljs * sqff
vftv: 3
ljtw: dmbg + hzhf
dbth: tszl * vpdv
tblp: 3
jnqr: nfcq + nrdc
hzsg: hscb + jhjf
njbt: fths * lqlp
clpj: 2
nlzv: 13
nqsh: ljpc * zhjf
vpjz: 7
drlj: 4
djpg: gwfq / djtd
dslr: rrsb * wtcb
vlqj: 5
msht: 5
gwjm: hrvv * pblw
mcsm: fdmh * lnsn
wwzp: 2
vdbq: 7
gtfz: 2
mchl: prjp * phdl
tgvf: 1
pplm: wphd * njbp
jzps: nwqn * bdvw
fvqm: htqw * lzqv
jvtr: 6
srmg: mwgw + gqdg
vlgv: fbls + rfbj
zrbl: bgsw * dllv
pjsw: jjwr * bjnp
twpb: dpsp * jpbs
ftnw: 2
nsvp: jpdg + dzzc
nszr: 19
gffg: mdfl + sjcj
tncl: fppn + pgnh
wglt: 12
pfqq: zsrv + rlzn
hjsw: 18
wcbw: gnsg / jsfs
vdgf: vrjr + lnrd
wvfw: pwdp - mbqg
lvtd: crpp * snbt
qmwm: 4
mhtm: hqjz * qrwj
ffjs: 1
cmhd: 3
wgpl: 4
npnv: 5
bgsw: 18
jssm: 2
mzpv: 7
pvzz: 2
pcms: 4
mbrr: mwwf * bwhb
gmnw: jgsn * qnfb
wzjb: 2
qffn: rcrv / jqfq
nvmp: 5
bdds: hqmn + vhjv
nctq: 7
lswd: 2
qrcf: gqtt * mhnb
rlhc: rnhr * jtpg
rnlj: 3
pnhw: 4
fswg: 19
ffdb: mnjr * fnpv
mhnb: zvjg * mljz
tsmb: 3
gczs: wdlg - zqjs
qzcq: 2
cvbz: phjq + pbzw
llzj: zmqb + wvsc
qdgc: gczs * qwqw
vjph: 11
mchq: 5
stpv: 17
mqzg: fhhh + sdqd
jcvd: qqlq + pwmf
srtj: 13
fvhj: 19
pbfd: 5
qgbp: przd / wdqq
gbvr: 9
qnnl: hnhp / wzmm
gqvv: tpbt * jnhg
tmsh: gbgw + hphq
nbft: cghj + zrvn
bmmc: lrvl * ssph
hmfz: wdll + rdsl
prsr: 11
fhqm: 20
dnzn: fvjt * grrb
zcvz: 2
qcjd: cwpc + lmvq
szsh: 5
stsc: ndzf / ncgq
hlcm: hnmm * bwcw
bhdt: hvsm * fbpq
rmfd: 2
ssvr: 3
fshs: bncl + bhjr
hhnt: 5
tttq: 2
jsfs: 5
npbq: 3
mqsc: qjlm + qmvl
fvpc: 2
mfzn: cfzt * qhwt
pvgh: 7
dqpj: 6
nttm: 2
frjf: 2
hmcv: 12
blmj: hmls * gblc
rznv: 2
dphh: mqqh * zzwg
wwhs: 2
jcwp: 4
dbzz: 6
fcbn: cntc / vshb
hcmh: hzzp * zgdm
svmn: 3
drsb: qcfr * hnlt
qspl: 2
ncdw: 2
tfcr: 2
qzqz: 3
shcz: 10
jcqs: 7
bnzz: zqgl + snsc
zgdm: 3
tsjb: 3
drhv: wtnb + hpfr
wdjq: 10
nnnd: nntm + qpqs
qjlm: chzd - czwl
wwvv: hnbl / vbwd
jfqj: qvgc * zwnj
zrqw: 2
tsdg: hhdm + bpgc
lzqv: nltz + qlst
hcsn: bfbz * jvpg
gqvp: gbrr + wgfc
nzvf: prhh + czhh
ndzz: wrrn + ptcg
ggpb: 2
djbg: jdvb - vscz
hbnm: 5
rrdq: rfcz * hbmp
jdwq: 5
sppm: 3
brlz: jcdw + mcnj
hmrb: snng + mcnt
ncnp: 2
znnj: ptbt + bzfj
jpbs: qlrw + njbt
mrrb: nhfm * vdpq
jhpf: 4
fgbg: dfmb + hvjj
zjps: 12
fhlm: 3
vndh: 3
mvbv: 3
mcvf: nwdj - jwwr
lgst: vrvr + lsth
vzft: mdlm + tmmf
vjvn: mrbb - vhdh
mfjv: zlbp - qnqp
pcpr: 2
pdmm: 5
qlfn: frlb * wstm
ggll: 9
thqs: bjgh - nwfv
fqmr: 7
blbw: tqft * mhfc
jdbd: 9
pcvp: 5
prpz: dpdn + gblb
rnrz: 4
phjq: 4
dhsh: 2
ljjb: 5
lnrd: nwcr * wzgl
bjbd: 3
lllf: 12
jpzq: 13
sbll: 4
hzhr: 3
cqwn: dmbl + rvnc
vbth: 3
hwln: llcr + pphc
gmbw: gslc + jhgf
qvqq: 2
bgsq: cpvn * nbjt
trbp: drlm + csgs
cmrm: 5
fjrw: bzqz * lpjt
pcgj: pctv - zhfd
cmfn: ctmg * wnvb
hbmr: 20
tpbt: 7
lvdf: stbv + tptq
btgt: ggnb * lwpm
fglt: jnzm * pcgj
slhm: 2
wzjj: jppl - wcrj
pwdz: gndt / jsrs
ntcs: nhfg * jtbj
qfsg: sqjj * rfwn
dfld: 3
lbhh: 17
lhml: 18
lnwm: hcfq * qlbt
fnvn: npwc * fssv
nrdv: qrhf + ffvh
pvlz: tnvn * vgbd
npct: hqbr * ftvs
mhmt: 2
bvzn: szwz * dmbw
bsrp: gjsc * trbp
jpvw: 5
pqcp: 5
scwd: vzgl + nflt
npqh: mmqs * pwdf
wmbh: hfbb + ljcm
wzwp: 2
bdvw: 5
qcjg: 3
gqtt: 6
nncr: 11
djzn: hbnm + hpdd
qcsg: crhs + mqqt
rbzj: jnbd + cjzt
rzzf: 2
rfdf: 15
qnqp: pscr * vfbb
djgb: 11
cpfb: jpzn * dslt
hhmq: pbdh * qbgz
hfnn: 9
bsvd: lbzl * wqmt
qgrd: 13
lttd: dtdq * pzfd
bffq: jczr * pfph
smqr: 2
vrqb: hqbt * rdpp
npmd: vvwr * smqr
mnrs: 2
nqhd: wjpt * vgqr
ggzt: fswg * fqrj
mdrc: 18
stcj: nfgw * zbbs
zhqf: 7
lncq: 3
dsrn: prcs * jqjm
jhgf: 13
qlbt: dnsg / gtfz
mnrh: npzq * hqhv
cmpp: ggjg + dzdr
nmzl: rdmt + zhqv
humn: 1342
lpjt: gdcj * vfrz
wffm: 2
pztq: 3
rfmb: nnqd + chwl
pvsc: dpwl * ppwp
pspv: nfzh - lhpg
gflm: 7
mvvt: ntnd * sljl
cggg: jpvw * tgtn
gmrp: bhgc * ffdb
pwld: zftc - qphq
vrlf: 2
wclb: tbwd * ccds
jzpn: 8
zfpr: 4
gcln: znrf + tbpn
wrrn: 7
wgqp: nttm * cljq
hrgg: 2
lctb: tgsc + zwrr
llhf: 3
zfrm: bgws - fmjc
dtcf: 3
wdrq: hcts + mzrj
hlht: 7
jcpj: 4
tbmd: gnfz * rfrm
mffn: 9
tgsc: 2
hzzp: 2
tltn: 3
bvtd: msnd + srsl
gvpn: ldnh + slmh
rfcv: spbn + qmhg
lgln: nzhv * zzhl
smlh: 3
cszj: 5
jssw: 5
scbt: sfrm * zrpj
pqrq: 2
pvdl: 2
dpcf: grsv * mbnh
lfrm: 13
rdcj: mqcr * bhqd
zswn: 6
hdpr: wrfn * vrgz
bqqd: 2
qrgh: 4
ssng: 12
rpln: 4
lvcn: 3
vqmc: 9
tchh: cttg * hlqd
mhmw: 7
bmjc: vlzm - hzgc
hcmr: 18
jtpw: rtvg * zmcn
ldcj: psmc + ggrf
qqnl: 3
fsqc: fzms + hbns
gdqr: mjmv * jgfp
wgvm: 2
nhpc: 5
wlvr: vcvh + ltsr
hfmd: 1
cfzt: qlhv + fsgb
nrnq: 4
czwl: rrtr * gzfn
spnp: 13
qzmv: fsqc * rnpf
qlrw: jwql * gmnw
pggp: 4
vvlm: vftv * hfnn
hvtr: brzp * qrcf
wrrz: 3
dccf: 3
sscm: vhqf * gnzn
sntt: bgqf * flhn
dtdq: btls + vftj
tnqp: 2
rcpw: 4
fjrd: lvnq * lpqd
dvlb: svpw * qhvb
hpdn: 16
glqg: 8
qwjc: 1
wzhp: 18
rghb: wwms - clhb
prdc: sjwq * vmwv
gsmv: 9
hqbr: 9
ssph: 2
stfs: 3
dmmh: 3
fsqb: 2
ttzn: 11
lgpm: 2
tvrj: 2
srnv: 3
nsbz: 5
zvnj: svmn + njrg
mmqs: sbjz + wjnt
mrgb: qgbl * cnrp
ndgq: fjjc + bgrd
hfpr: 2
tbrw: 2
wzts: 8
zvsp: jfnr * zvhr
fths: srvg / vqwv
hzhf: cppj + fzgw
hsdq: 2
whtb: wjwz - rqzq
dctv: 5
pfzs: fdhc - bscd
mtzs: czgl * fwsl
nrpj: cmpz * tflj
hphq: wjgw * wrrz
cbvd: zlbd / vcst
lltc: hnvb * lthz
mdrn: 5
jrrq: qqlr * tqdc
mzgg: 3
bghc: hznq + hqdc
zvjq: 3
tlgz: 6
ftbp: wjjp * stcj
tfrq: bqbl + gwjm
wgdz: psvd * gqcv
jrcr: 2
wwms: rqmw / dbqq
wfqh: 3
qgfq: 11
twzm: mchl + bwgh
cgnv: dvcq + hgvw
rgqh: 20
gbzb: 2
cwzv: 18
vpcs: 2
fvwq: 3
bdsd: clls * cszj
psdm: 9
hpdz: tzwm * mdwn
lrjv: 2
jrnr: hwll + hrnj
vddh: 2
hgcd: bbjq * mqbf
glps: 3
mbgw: lzlf * tndn
nlfv: 13
njpf: vrjq * rgjt
rfrm: 2
lsdf: qrhv * ldcc
ljng: lqqq * jccn
tdqc: 3
nrcs: hrbq * gcln
hclm: scbt + grgf
rnsd: 1
qqht: frpq * bpnz
dtww: 7
nhzt: 2
ttff: vfmv * nwzj
gspb: 6
zpft: 2
ldgd: fhlm * tmhf
wsfs: wbwf * wzql
vmjl: zbmp + nrsw
bpqv: dtcf * rdqg
qgmp: njbl - cmwh
zhqv: 2
tcqs: zhpr * tdnb
btjv: 7
zcbw: rfmq * rcgh
qmjb: 3
mpch: 5
lwpm: 13
nhtd: 2
rhzn: 2
prwg: 13
cmjw: 3
wvsj: 7
mhgb: prms - nrjf
wnzg: tnrd + pdvp
gsqp: 3
hgtf: 10
fhbb: gzww / zdsd
jccn: 2
blhm: 3
wsst: rlrv + fppg
szgd: zvbh / vbqp
jclw: 12
zztb: qgrd + hpdn
tmhj: zplw + mmdc
sqff: 2
djwb: wtjz + lltc
vplb: tbmd + tqql
lfgv: cpzl * cvgp
vrjr: mbtj * rfcv
bjwc: 4
sstq: 2
bdjw: tfwm * zqdb
rhnf: hlsn + zgjb
ffbt: 2
vbbn: zqtd * jfqj
vfmb: pmdd + cnlm
plms: 2
dllv: fzrq * hmfr
szvz: dgfj * frdq
wjhj: tznf + hvsg
dnnp: dnvd * fbns
mmlh: 15
zqzr: 7
pjpg: 2
csdt: nrnq + blmj
vwdg: 5
pzfd: 4
pblw: 3
zcfq: jbwl * pvqn
thjn: 5
zrmr: 3
brvb: 8
qqch: 2
zwdr: 3
rphp: sctg + cgml
wstm: 5
vmhp: vhns * zqqs
sgst: 4
vvnh: 6
jsqp: 8
ztbg: 3
rqzq: fbhm * psdb
nqwl: jzps + wrlp
fbls: 1
rlzn: qhjq * bnzz
ccrb: sgcv + pcbt
pdbl: dtnc * jhdf
lbht: 4
pdhl: 5
jvzn: 4
jtjj: 2
wdpz: 5
lhpg: 2
fcsr: mvvt + fccn
tgsp: 3
pqdz: 2
rmjw: 2
jcwh: 2
qppr: 3
tzwm: 18
mqhl: 5
qwns: 1
tztr: rpln * cmsd
msvl: 4
sjwp: qwjc + vnvw
vjzr: jwnj + bdlp
gsdr: 5
zhmd: qdgc + mlrb
vnrr: 9
tgwh: 3
slmn: 12
gvfg: 7
fbhm: wdqw + hpdl
rshj: pdhl + qpth
dfjn: bpfl + ztqf
nltz: 13
zwcz: rdqs * gzhz
vmqt: 4
gnzn: 4
hqnr: ntqn * wvlr
wdvh: 2
brbh: 2
ggnb: bfrh + ccdl
gbnd: 19
prms: hcpl / hqlq
whdr: wwnj * mcmn
wzfd: 2
svfq: wjfj * wffm
zgvg: blgc - psfm
zntm: 2
zgtr: vtch + wppb
hbvd: 14
jczr: llzl / mmcc
vstr: 2
ljhq: zvsp - gfcd
hqbt: znrp + whth
sjcb: pfzs / rwqr
prbs: sjfb / dnbq
tsfz: 2
sjqr: vdcd * cncc
zzrg: 12
gfvd: dnlc * gljf
qmzp: fhqr / hrgg
hchn: 10
nvjn: 3
twqw: 4
rdrs: 2
dgww: 9
bfrv: qshd * djbg
zvfc: 3
mtpt: 5
zqcn: 11
cwff: mffn + dqbq
hhds: 7
qbbv: chbn - zntm
tvnp: zgtv + qnpz
vdcv: 2
qgzb: 4
htcn: gnpd + ntqj
fglh: 2
wjlh: 7
czhh: qvqt * bvqs
jwcv: whhd * nhgb
mcnt: rvrp * qhvt
mchz: bsgd + cwwf
mcmn: 2
wjjp: tjcr + gvmd
wnms: zdqz / lplv
dcqm: 3
hqch: jlvt * wzfs
cvvp: dccw * shpg
qhnd: 8
ztnq: 2
lhcg: qtwt / sjdl
hpmd: sbvg - vlqj
gddh: tnqp + whpr
jcsw: ncdw + lllf
vdcd: qzgr * mdgl
bjcn: 3
rvnc: 1
pwmf: zwdr * rmvz
llzw: zshc * nvjn
dftz: qmdq + dbqz
jnhg: 3
cppj: pvzz * rpbl
fhrb: 6
bfwn: 3
gqzz: mtmh + vbmg
cjzt: 5
tfdv: 2
pnvf: 11
qsjh: nnnz * vntl
svln: 3
wznw: 5
svww: 9
wfzs: 2
vnhj: 20
zbhz: 2
zrcm: 3
qwjp: 3
zwrr: dwzz + nnnd
wbqs: blbw + jrld
wfbz: jshj + dnzn
tsvz: 2
qmdr: 2
nscs: 3
znvj: jgcf + rfmb
qbjg: 6
rfcp: vgsf + npmd
czbj: 8
qzdf: 14
qjft: rdzb * zhlb
hphz: svln * bgsq
pbmt: rbtt / nfzd
pfrc: 20
zwnj: 3
wnfd: qqdw * zcfq
pwdp: 14
jdmc: 2
jdqw: rbrw / vmqt
bmmg: nbmh + ftqp
jcnn: 8
zncf: 13
jqfq: 3
psmc: nctq * fhqm
dmhg: qmzp + swjc
pjbz: dbpp * jvpl
cgml: vhgh * gbrj
zqtd: 3
mvdw: swcn * qgnj
jfrp: 2
qsrf: zrlm * nwqb
qhjq: 17
jzth: 4
jcjs: 3
sjgn: bbnq + pcch
jpqz: 2
nztn: 4
bpns: msht + jclw
zdmp: 3
hqmb: dlcz * glpn
lfjq: lgpq * bwdz
fwlb: 2
przd: gdqr + fhql
vbht: rphp * jtjj
phmr: mrwj / nqcw
cqmw: phmr * rzmd
smnp: 2
ffvh: tdqc * bzpt
mnqf: jnct + hnct
sdwr: zclc + nqsh
cfrf: mlhf / sgcb
tptq: cdbf - hhbj
bszn: lhml + tfpc
mzsc: njtt * mcqn
crzd: 3
nsbq: zfbr + qbnw
wlbm: 6
cswj: rczm + tlgz
zbzr: 2
tqft: 2
gpcg: 2
srvg: zprc * djgb
ssqc: 3
rwqb: 2
rdqg: 9
qpwv: pwtz + pmgn
bscd: tsjz * qmvc
mqcr: 2
mgws: hprc + nrdn
gdfr: wrcr + jvpm
tmzd: 3
fzrq: fbpw - llhf
tbpn: zppc + dqpj
rnqh: lszf + pfbd
htqn: 9
cncz: qpdn / tnmv
tgtn: 2
zrtv: lfcg - grgs
gsgf: 6
dwnf: snjr + tzft
psfm: ttcq * lttd
ztqf: jrcr * vmjl
zhbn: 17
fwsv: 4
bpnz: 19
rtmt: bgrl + jfbb
jnrz: fvhj * ptjj
zvhr: pvpg - dmvm
vhth: 1
gblc: 2
tcrr: 3
nbmz: ttsh + frzv
tdbn: brqn * mhzj
brzp: lrsm * jjbm
ttcq: 5
hccv: bpfj / vdcv
jmrf: 13
pjlg: cfrf + bfwr
znrp: 1
bnmr: rwqb * qmcg
zjzs: lqgr * cbvd
wjbf: 9
fvbq: 2
qqqp: 6
bgqf: hzwg + ztdt
clhb: ddzr * mssp
hlmj: nrzv * nsfh
llvf: 3
mtmh: wzsh + cffs
ztjg: 4
dwqw: 15
ttbb: mtzs * qbjg
tmjv: tltn * vjvn
wrsf: humn - pjsw
pqtl: jjjz * pnrd
smpc: 5
cbws: hbmr + qdrm
qjtc: 4
ggjg: 4
hhnb: fvpc * tsvp
pgzn: bghc / mchq
hmfr: 3
msnd: 5
hnmm: ghqg * cmhd
bvwp: mfdj * mwvg
tmgq: 3
nfjp: hfvw / gdnj
nsjn: nwcz * hvwp
bsgd: jvmf * zltj
gfcd: 8
mbwc: mvbv * ndgq
npgd: hhnt + smnp
tbhv: 11
zdsd: 2
mhch: 3
nwqh: 16
gzhz: 3
frsn: 5
zhpr: stpv * mqvq
pnvs: 16
wfjf: 2
pfsv: 19
zhjf: 4
htzn: vhbl + tgvf
zbbs: 3
cpzl: pbrd * mgws
jrfb: vvgt + qzqz
fsgb: fbrh * vjph
jlff: bhwv * tfsd
whhd: trfc + zjdz
lqht: pjbz + qvql
wphd: gbtz + zclt
lfgc: sgns + bqvr
bvst: bhfl * qqnl
cflt: lgpm * mhch
qhlm: 4
jhmj: 5
whpr: dccf + brjv
fjlv: jpqz * mfrr
mpjs: ltcn * vjmr
jfnr: rvqw + clpj
dndb: mjzn + jhgp
cljq: qmrs + gnpz
vlzm: jgfl * wsst
vgsf: 5
rwgf: fwtg * zwcs
trmz: 4
bwgh: mrst + hjdh
vszn: fjlv * sjgh
pwsg: qlcr / jcjs
clwf: pftj * cwht
lrvl: ssbm * flwl
glpn: 2
gqlq: 10
zprc: 2
qdtr: 10
jgfl: 4
gdnl: 12
ssbm: 5
cdjw: vbbn + vntq
btls: zwcz * wznw
mzcr: 3
mrcm: 3
phps: bnnw + fsbd
nsfh: 2
qwpg: 5
bclh: 6
dmbg: qqch * mfdn
jcjp: 2
fqrj: 17
vvmd: 4
frgg: pnjv + pvlz
nhfg: 2
lqqq: hdvf * wcps
mltz: bmmc + tbmr
tgts: mcvf / rdrs
lvqb: jphc * rvlm
rzmd: jjfq + lzwz
jnqw: sfvg + jqbn
tldj: jcbp + fcns
fbtw: tjzp + bszn
npzq: 4
rljl: hpwf * gmhr
fbpq: mqsc / fwsv
mvsd: 7
hqdc: vwcj * rpcb
zbnw: nvff + mzpw
vcbn: szsj + pdhv
hqhv: qmwm * cqfp
mhzj: 3
rbtt: dprf * twzs
wmmt: 3
tsjz: qcjd + dvrd
rdnw: wvcp + btgt
zmwp: 3
hnlt: tbhd + drzh
ffcz: dnmj + wcbp
vdtj: 4
cdbf: qcct + fcdf
nqvl: jfhf / dnpj
gchc: zfrm + hvtr
mdwn: qrgw + srmg
zljs: bmnn / jdmc
qdzq: mbwc + cqmv
chsp: lbbb * wmbh
zctw: vplb / zlvj
snng: 1
gcjz: 4
gljs: 4
dssz: qcwr * rszd
tzsp: zqcn + bmcp
pdfq: 8
gmld: 3
tdlv: vvsm + qwfc
bzcn: tsdg * qvvn
tnvn: sbfb + nlwj
sqcc: hfmg / cdhb
rpbl: vwnc * jddn
qrhv: nvmp + ldgd
bjnp: pbmt * gflq
zrlm: 2
nvmr: 5
bvvc: 13
wqch: mmhg * rppz
zrwh: 2
rfcz: 20
mlhs: 2
ffcn: 15
dtdj: csdt + jnld
lsrv: zhqf * btjv
qqbd: jnrz * hgcd
rpql: qjsz * lvpl
swtj: tmhj + gmbw
snjr: 3
ptjc: mnrl / zcbw
nqvv: ffcz / wrqd
tfml: tfpm * cgtg
grgf: 5
npvb: 3
tqnb: 2
qqdj: 3
cpjn: 2
fgdw: 19
dpwl: 2
cvvb: 4
vvqq: bfnc / mhmt
zmcn: 11
chzs: 6
ntlg: twbf * vzhj
hqnz: lrnh * sqcc
dccw: 2
fhpt: mrgb + ggvc
pmdd: lwdc + pvgh
ljpc: crdq * fqmr
ztdt: rmgn + zthq
hqjz: 2
jnzm: ljqw * dmhg
hcdv: 4
bzpt: 13
fmjc: llbw * hnfz
nnmr: gfmb * qwjl
twtg: 3
lpzn: pwpp + smbr
glmd: 4
nsrr: bvnq * vwvc
dlrc: wwgw + ftpg
vzhl: 5
cbgb: 10
jgfp: gmbg - fbnq
hvwp: 2
cbrp: wfqh * tslc
nqbp: 3
jfbb: fghg - tssr
tjbl: dgdr + gqhq
hfcl: hmbc * tmcp
vntq: gqwq * qdtr
lnsn: qgzb + npgd
dvcq: 5
cmmj: 3
znrf: tlsr * pnvs
hrnj: 1
stcw: 5
crnl: 16
wdwp: vhth + tgch
fqgg: pzgm * jcjp
zqjs: 4
chmf: 3
gslc: 5
jsqt: 15
jsqw: mltz - zlsb
dfnh: 5
hjds: 3
pdhv: whtb * dbgg
sdpr: 2
nsqn: pcpr * qjjz
bblr: crjp * tfdm
vztj: tsjb * rght
lncv: rhnf * sflq
gmhr: 7
hwbw: 5
rlds: jdgm + lzvn
zgjb: dlzq * lvcn
gfzs: cpfw * zqfs
dzbd: 2
hjdh: jrrn * rprh
flwb: rfwp * hcsr
nrjd: tbdp * hzsg
wjwz: gjgw / zdnr
blgc: tlfp * jrfb
hbmp: rbzj * jvzn
vzgl: sbwb + twjf
jhgp: 1
cnpl: 16
nlrq: 3
jvmf: 5
jhpr: drqv * vdps
sqnb: trzt + gdsz
zbmp: prmp - sqsc
sjvt: rhds + nwdn
flhn: 2
tqsm: 3
zqdb: 5
cfch: 11
vmhr: 10
gbqp: 2
wttp: 2
hmls: mpbg - fhzl
lvpl: wvdg - pzwn
tzft: 6
qrdc: 1
nrjf: 4
phdl: 4
crjp: 3
mjnm: 3
cthg: rfmr * bwll
zzzb: 1
hvfr: cvjl * ftpd
psvd: stcw * hbvd
tqrg: bshs - cgzs
hgwg: fgqw + gbqz
hmch: jswp - fqbn
cqmv: tpmz + stsc
jcsq: qghq * qjcz
qpqn: hqnz / zmlm
lzdp: vpjz * zsvn
bgsz: fdzp - hzsh
vqgm: 3
thjb: mchz * tvrj
bfbz: 2
jhdf: 3
prcs: 2
mfrr: 4
brpd: 3
njbl: prdc * hgcp
sgns: 3
tjgn: qzcq * hrnf
mfgw: 2
jsqn: zljs + bjbd
jbls: jnhj * wlwv
ltcn: tchh / jcnn
jhcr: ttcs + jmvc
fdmh: 2
vcst: 2
tvmj: tzmm * vndh
vrvr: lgln * qwvl
rmrr: 4
jwwr: ffcn + fmjb
jtph: pvnt + hpmn
brqn: 12
nqcw: 2
bfwr: nbmz * pplv
cdhh: qwpb - nzjh
zfsf: bhbm * lmcn
bhjr: ctth * wvsj
sjdl: 2
prhh: 4
zppc: hctp / cgrh
bcmd: 3
sglm: 5
zsfg: mpch * plgj
gdqd: 2
qbbz: 2
hhdm: hchn + cpvd
qdbz: wjhj + gvht
dpbn: 12
snfh: 3
vhqf: vpcs * gqzz
mhfc: 4
qcct: wrth * tbhv
twmw: 9
pcmd: 2
zmqb: 3
jfhf: bmbq * wmbb
brjv: 4
bmnn: sfwz + qzmd
pvpg: zvvw * bpjm
nnvt: npct + cgnd
mqzv: 4
dnhb: 5
tndn: 5
cdtl: 2
tvdc: snfh * wgfr
rlrv: gphq / qlbs
wdnm: fvmv * rtrc
cnrp: cgnt * djtc
bdww: bctr - fsqb
fbdq: clcj + wjtd
bvlv: fmdb * jmdz
lpqn: 3
jdsb: 5
mvrp: 5
lwcm: 3
ndbs: rnnm * jcpj
cglz: znnc * ptjc
hwll: hjls - jcsw
spbn: mpbr / grln
lhfl: bvrn * sjht
vlft: 9
bjln: jzqd * hpzr
lrnh: pnhw * dbcq
tzgl: mbps + rhgq
wmbb: ncfz + tmfb
dwzz: twcm + dslr
fvjt: 3
pgdm: zbzr * qjtc
jtpm: 2
vjss: ndlq + hfdq
hfvw: hzhc * zbjp
rght: 9
djtd: 3
jtwm: 10
mslt: 2
hhwh: mjrf + zdpw
ftpd: sdmp + qrdc
tqql: fbvc * bvmd
qmjn: ptpf + nrjd
nbcp: mzsc + sppm
lvlg: 8
jjwr: 3
ccdl: 2
tzpw: 3
prmp: dnhb * thrm
shnm: 9
vqjt: 4
njrg: 4
tfpm: fdjr + hzpg
vcgm: 2
jnld: qhnd - zzzb
pwfn: 2
jqjm: prbs / rzzf
wrnp: 2
ctmg: wgqp + wrqg
drzh: 4
qqdw: 11
cgzs: qgfd * sqnb
bzfj: mvdw * hwcg
gwcc: 9
chsw: thjn * hmqs
bgrh: gffr + nmjj
bbwp: 2
fbns: stfs * lwcm
clls: 3
rcdh: pplm * cmmj
vwnc: fcbn + wdbm
trrt: nwgd * hcdv
nplj: 18
tlwm: wvml * lzlp
mzfw: mzpv + qqht
mqrc: 16
ndlq: gjwj * gddh
jqdw: dbth * bjcn
dhdh: dqmj * tvmj
bzqz: 17
tfsn: fplw / gsgf
tbqg: gvfg * qhlm
jsfb: 5
fngh: qrgh * gwrb
drlm: dcqm * rbmm
vwrt: wdnb - jcwh
slmh: zhvc * zsrg
rqgq: hhgt + svng
gwfq: jpdt + qhpv
stvc: crcz / hcmh
ctcp: 2
gdrl: nztn + rdjj
wvcp: tcqs + lmlq
bjgh: tgdq * plms
dlzq: tmqj + vjrs
jshp: rvfp - tpgs
sgcb: 12
zszf: 2
mbtj: qmvv + hclm
sswb: gsbn / hdnn
dmcb: 2
bncl: 13
tdcc: 1
wdwr: 4
zlfm: 2
mmcp: 2
gzsv: fglt + hwln
pvnt: 13
nhfm: 2
zvjg: 2
jwhr: wgpl + hhnb
mwgw: fjrd + hjrw
cvsb: 2
tpwm: qglr + tnmz
bfsc: 9
pfwg: nchs + wvfw
gbrj: 3
fmdb: 2
hqdn: 3
dmvm: 2
cwvm: bqqd * qsfb
lbzl: 2
pphc: lfvh * tblp
jgrd: jzhz * pqrq
vtch: pqcp * drdm
ggrf: mqqs + hmch
zfrc: vqdb * sjwp
cgrh: 2
wzws: szll + qlfn
lscw: 2
lzqm: 2
jvpm: 3
zcsf: 2
wbwf: 2
gwgm: 6
mlcw: zqjl * spnp
sjcj: psrr * nvdq
qrhf: mzzl * dfcv
swzl: zbcw + tjpj
rdpp: 2
jpzn: rgqh / ccqq
vhrc: svzj + qqwg
prqv: 3
bhbm: 2
rvbn: 2
drdm: gvjm * vwdg
qcwr: 5
tzcn: 2
tcpf: vbht / jpdw
bccv: zfrc + rpsc
vrgz: 9
svng: 5
svvl: 17
gcrd: vdgf - bjzb
jfpv: glps * pngh
wvmv: lggm - lpzn
nltt: bwfb / gbqp
gtjm: 2
wlvl: 8
jczp: 2
bjpr: 5
tmjs: wgmn * hqnp
mqvq: 2
cmpz: 12
qqtc: 2
fbvc: 2
pzwn: wjhg + hcnv
sfwz: zhbn * vstr
lpfg: 5
pjdp: 2
bncq: nbft + vbvf
qglr: plgc * bfsc
vvpb: 2
ltrm: mcsm * djpd
tdgl: 2
wzsn: vdmn * rmfd
tmqj: 5
wvmm: 1
trlw: cbgc + jlnj
nbmh: 1
hcts: 6
wrcr: sbcl * hbtb
gqcv: tjcm + rmfr
vshb: pwfn + qbhg
nvdq: 3
rzfz: zjgt * rljl
hrnf: htcn * nghl
zppz: dnnp - lrpc
qvmg: 2
sjfb: nsjn * swzl
stfm: jppq * vqjt
hvqz: vmhr * vbsv
ptpf: fbvd * cflt
frpq: 2
jzhz: 3
dlqt: 11
lsfg: 4
pplv: cthg + rnnq
ttlg: rrvl / nzdm
bltq: lcmm + bpns
rfbj: zptw + fwzt
lgnj: ghtq + tjgn
dbpv: bmdc + srtj
vhjv: dzbd * fjhr
svpw: 2
qwjl: 2
qrvv: tzgl * lmbf
zjdm: 2
mljz: 3
fdhl: 3
hbdh: lddv - htzn
mcqn: 2
ttcs: 14
rpcb: 3
qmcg: hvhj + fghp
nzdm: fglh * lmzd
dwww: 12
ppzf: 2
qwwl: hjsw + bdsd
wdgw: 5
msbj: 9
svzj: 1
prvz: nctf * srnv
drft: 4
jzqd: cbws + tbqm
mnzh: 2
zpsb: trmz * bsvd
ssbp: gldc * wfdv
zgqm: gldq * cgnv
cmsd: brbv * pccf
vmtd: dlfn * snlv
glws: wzjj + gwgm
zptw: frrv * hzrt
fnpv: jdsb * hqmb
gctl: ndzz + chzs
znnc: hwmg + chdw
tgdq: gmwp * qmfz
vftj: vjzr * szlw
rjhw: ttbb + dqvf
nfnw: 9
gjwj: 15
jgmg: 2
dngr: 3
gjzt: 2
pwpp: lctb + wzph
gwpn: pvqq + gczg
lhwn: 2
mpbr: 14
fdzp: jllh * dwww
bmnl: nnhf * twsc
ggnn: nvns * wvcs
vmmw: 2
tbqm: bhdt + wjsq
wsbv: gsft * mnrs
jswp: wvrm + hlcm
dzdr: 2
mmmf: 1
vzhj: vzhl + wzhp
srsl: 2
htvj: whzz * nbcp
gdzh: 3
twjf: vgzr * bmmg
hzsh: qwns + tmjs
dqzp: rmfw * lpqn
dbgg: 2
wjnt: hbdh + rnqh
vdpq: dlmj * ltnc
jnbr: wdgw + prgp
rhvj: 3
bcnh: 11
ztql: 19
gqhq: bdds * bbwp
pgpg: sndc * tvlz
mrbb: msbj + nsjg
stnh: mzwg + gwlf
hzgc: qtrb + tsvq
bwts: dwqw * jdqq
jjbd: jhpf * csbn
rrvl: cqwn * fmfm
vwvc: 2
tbmr: hvlg + qgld
sbjz: mdcb + mspz
lbhd: 3
jbcb: trcd - ncrb
wtnb: 6
frjt: bffq * hglp
wzql: nszr + tgcd
qgfd: 3
vgbd: bmds + fpdc
jnct: 4
zwdd: dssz + twqw
zvbh: fbbh * jtpm
nfgw: frjf * stnh
cvdp: rrdq + tgts
mqqt: mbrr + hfmd
cdmb: 2
pvch: wbft + vmtd
hgcp: fbdq + ztsp
jmdz: fvbq * pspv
bvqs: 20
fmjb: ttlg * ntrd
zdnr: 5
zftc: 12
slhd: zmwp * jqff
hmqs: bzzl + zhmd
vbwd: 9
vhdh: 4
jqdc: 2
ltnc: jvtr + jnjq
qvql: pzmr * lqqm
cbsm: rdgb / gttj
fbpw: 12
dpsp: 7
vvhd: 13
vwnd: 1
bmbq: 2
hbqw: 9
ccds: 3
bhfl: 3
tpgs: swth / wzwp
swpr: slcg + pnwh
hlqd: 2
zwbm: mnrh + cpfb
qdlj: 2
hnfz: fvqm / brbh
qqlq: 3
dzwg: tfml + phpv
rnpf: 3
zngc: nnfl + hbqw
fmds: nsvp + rlhc
tchr: dzwg * mfdb
tgfz: pbps + fbrs
nwmh: 3
tnrd: pbfd * blpr
zgtv: vblr * frsn
pzbr: pwdz * frgg
nnfl: 2
mlhf: fqrh + sqjl
tscm: ggzt + tgjj
dsbr: thqs + pccp
zfbr: tsfz * vztj
mbvj: zjzs * dbzz
wdnb: qlrf * lwgd
rmwz: tmzd * ljhq
hpbc: tjhw * cvvb
mrwj: ncnp * tjbl
qwpb: sbqt - fhbv
tflj: 5
nlwj: 3
ghqg: 13
vqzw: dfdc * qspl
wjfj: 6
hcfq: fqgg + pzbr
nchs: qgrs * fwlr
pmgn: bdfj + slmn
lzwz: vvbq / lsfg
hqlq: 2
hpmn: dttn * jstb
djtc: 2
dccl: tgwh * msvl
ldgh: cggc * gnqp
jsvp: gsmv * tfcr
mbps: 4
dfcv: 16
tgjj: jrzs / pjpp
gzfn: 4
tjpj: 3
gbtz: cqmw / slqs
cphb: fwgr * fvwq
wrth: 2
lqgf: 1
mmcc: 2
qcfr: 7
vnvw: 12
pndw: 16
ptsl: hsnn * nmdm
zmfn: 5
psww: 3
ssnq: rwfc * nplz
bwfb: 14
fcdw: zgrj + nwqh
pjjv: 5
hnhp: rdpq * tsmb
gwlf: lmlf * hmcv
bwcw: lvlg * crzd
nmdm: 11
jjfq: znzl * tqnb
dfsr: 3
ntnd: 2
jnbd: 2
hmbc: 4
cdnl: vpcl + szgv
tmrv: 8
nrrh: gctl - cphb
nmpz: nbwg * qdjt
rppz: lqgf + tgfz
ggfm: 2
wzgl: 3
qbgz: 2
zqjl: 13
mpfd: 5
fbrh: jcwp + cqdw
mqnf: lfjq - qjft
lplv: 2
mccr: qdlj * pgnd
vdps: bdvv * ftnw
zsvn: chnh + cmjw
sqjl: bsvh - zrtv
nvbg: 2
djpd: zvfc * wtcd
pwdf: ldvj + znnj
szll: tdgl * vtbg
htbd: 4
lhfq: slhd + jbls
qshd: 2
ldch: 2
lpqd: 5
lmlq: bzcn / vvpb
ncgq: 3
fwsl: 2
rdjj: svdd / ssbp
bshs: nzvf * qvqq
wjgw: 11
nqmh: rlds + tsvz
mhhm: tflw * sszs
qdcn: 3
wdlg: lqjf * bnmd
gmwp: 2
wzbm: wzfn + chbq
jrzc: 18
npff: 7
tgvg: flbp + mbvj
rswm: swng * jlff
zsdf: 5
nvns: 7
qmvc: bblr + chpr
mdcf: nsqn + rbnd
ffzf: djpg - chsp
dnsg: dmnh + lgnj
crpp: 2
bswm: 20
wrqd: dlzm * mnzh
zztm: wnct + htqn
vhgh: 2
sztw: 2
mhgd: 4
tmhf: 2
vfzt: bhvl * fjwb
qmfz: 7
qzgr: 2
tbrs: ssng + nhpc
csqb: 1
nrzv: qgtn / zzlf
lsbq: vddh + whml
sjht: hjds * pjpg
hjls: lvtd + fshs
hbbv: vwrt * cvsb
sbfb: wvwn + sztw
hrbq: 5
qvqt: 2
btpg: fbbj + sjqr
jqbn: nncr + bgrh
gndz: 2
sjwq: 5
djfj: 7
phpv: bmjc + gcrd
gqpp: 2
rmfr: thcj * shnm
swqf: 2
vfbb: wrtb - rfcp
djcj: gblg + zncf
qzmd: 4
cprz: gtzp + hccv
dfdc: 5
qjjt: hbbv / gndz
tgcd: hlcp * hqdn
sjgh: 2
lphm: tffd * lfrm
lqqm: trlw * fnvn
lpmb: 4
dslt: gtjm * jncn
dctl: 3
pnwh: 4
fjhr: cmfn + lgst
bfqz: 2
vgqr: 2
cffs: nplj / ddmc
mjgz: 1
qqjr: 5
twbf: 2
qlhv: tcrr * wglt
qjjz: 3
hqmn: pfwg + rqgq
dgfj: 4
ztgr: 2
rssf: dsbr * ddrl
mhhf: 3
mqlc: 1
fmnv: 4
qstn: cncz + vwnd
pzgm: zgvg + drsb
rhnv: 2
zhfd: 2
htqw: 2
twql: gbzb * vwcc
znpv: 2
fhvc: dqzp * fzpn
vwff: 4
nsmv: hgfg * djzn
hrmd: 4
fpdc: 1
bclv: 2
ghtq: jgvd + pqdz
wtwv: 5
jrrn: 7
lrjz: 4
dgsn: 4
nhgb: lncv / zmbb
hfjm: vqmc + djqp
sbdb: rmwz - mfqc
bsvh: qbbz * chvf
nmjh: 17
hznq: wvmv * tgfs
nbwg: 6
qvbm: 2
fjzq: zqsq / pztq
lqgr: 2
hvjj: mslt * cdgd
hjbt: 5
lhcr: lndq + mbtc
gqgj: 3
hnct: 9
wzph: bncq - tmjv
ptcg: hmdt * jnqm
mdlm: 10
hwcg: 6
vvbq: wvwf * wlbm
vpdv: 3
nwzj: 9
zltj: 5
pngh: 2
sndc: 3
hnvb: 2
rwwc: ntlg - brpd
"""
