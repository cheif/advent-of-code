import Foundation
import Shared

private func HASH(string: String.SubSequence) -> Int {
    var curr = 0
    for character in string {
        curr += Int(character.asciiValue!)
        curr *= 17
        curr = curr % 256
    }
    return curr
}

public let day15 = Solution(
    part1: { input in
        let steps = input.split(separator: ",")
        return steps.map(HASH(string:)).sum
    },
    part2: { input in
        let steps = input.split(separator: ",")
        let boxes = steps.reductions(into: [Int:[String.SubSequence]]()) { boxes, step in
            let split = step.split(whereSeparator: { $0 == "=" || $0 == "-" })
            let id = HASH(string: split[0])
            print("id", id, step)
            let contents = boxes[id] ?? []
            if step.hasSuffix("-") {
                boxes[id] = contents.filter { !$0.hasPrefix(split[0]) }
            } else {
                if contents.contains(where: { $0.hasPrefix(split[0]) }) {
                    boxes[id] = contents.map { $0.hasPrefix(split[0]) ? step : $0 }
                } else {
                    boxes[id] = contents + [step]
                }
            }
        }
        let final = boxes.last!
        let focals = final.map { box, lenses in
            lenses.map { $0.split(separator: "=")[1] }
                .map { Int($0)! }
                .enumerated()
                .map { (slot, focal) -> Int in (box + 1) * (slot + 1) * focal }
                .sum
        }
        return focals.sum
    },
    testResult: (1320, 145),
    testInput: """
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
""",
    input: """
kt-,qtf=8,bh=5,mh-,mqr=8,dcnsc=2,kt-,kc=7,shxp-,vph-,cdnv=4,qbp=5,dq-,kr=8,hnxt-,jbt-,pn=7,hmk=6,rngnp=5,mpfqz=1,hfg-,nsxcb=1,bbvt=8,bzs=7,tqrl=9,rlh-,jrmv-,dsd=4,cgl=4,rhk=8,rpz=2,pxc=7,dg=3,pgvxfc-,gtvh=3,dqsx-,jzn=9,ggp-,zz=1,rtn=2,tqrl-,rqj-,nlkhc-,vn=8,lrmzj-,cdlvt-,fk-,nkk-,vpcn-,qbm-,sl-,bmh-,dg=8,jkkn=5,sr-,pfp-,bmh-,hkrpt=4,tv=7,bt-,vpcn=8,th=5,fz=5,vgtpp-,bppqt=2,brx=2,bvr-,ml=1,cspgj-,sr-,bg=6,pn-,pjll-,dcnsc-,rngnp-,bjk=7,hxfs=9,ft-,msvg-,hc=5,rqj-,cnf=7,bqc=7,nff=1,xzs=3,cz-,mp=7,mdq-,mjvmqv=1,kd=4,zvc=5,fp-,pvz-,ggp=3,nhkd-,np-,hksvq-,tz=2,kg=1,lvps=2,czs-,qsz-,jsks=1,sjg-,flc=9,kjk-,jkkn-,gfv=5,jln=2,hfl-,cdlvt=3,qgcz=1,rhk=3,rngnp-,hvfphq=5,tdk=6,kpsx-,hpkxd=4,mpg-,cpllbj-,zll-,qvl-,kpsx=8,vdc-,dvbxgp-,nj-,pp-,bc-,spb-,hjq=7,qvv-,fk-,bgqlk=3,fb=1,hhgpr=2,mkdgtg=6,fjhp=1,gvr=3,bqc=7,fs=4,fkh-,tsl-,snt=4,jvzs=6,rkz=3,tdszx=6,rsbmsg-,ph=1,tn=5,dvl=6,tvdk-,lx-,lgzh-,lm-,sml=8,ndn-,zxb=9,fhx-,kc=5,sfxs=9,tz=7,kjk-,ppfq=4,zrq-,hvd=9,pfp=5,kt-,lr=3,bvr-,smlh-,xhx-,fgv-,hm-,mfh-,bvr=4,qbm-,rgpdf=8,fdmj-,gzf-,dbr-,mq=2,bvr=4,ps=5,tk=1,jrp=3,bvv-,mpg-,fsps-,zgt-,fnpx=7,vh-,nh-,skg=1,kcv-,kg=2,xx-,vpvlq-,pc=7,xxq=8,jsks=7,sdb=9,vmcdl-,dvp=9,qbp-,gnk-,kt-,jl=8,nn-,sfp=8,hm-,jprr=6,bhv=8,rr-,jln-,rg=4,lk-,pc-,kc=3,xsb-,sx=9,gjdts=2,flp=3,rjlt-,qh-,rhk-,fdgdl-,mqr=9,ls-,dh-,rknsq-,hxj-,zcc-,lsx-,qsz=6,mpfqz=4,zgsf-,qpz-,bhv-,zz=7,xz-,fzd=6,mz-,dfvld-,xh=4,dvlct-,clx=5,zll=9,vl-,hglsjv=6,mqr=9,xp=3,cgl=6,ppqqz-,jrp-,sfxs=8,vgq=5,bzbcnx-,ppqqz-,hglsjv=4,sn=1,hkxl=9,cm=1,np=7,mhhvcd-,skg-,fgv-,kjx-,hrkm=1,bx-,sdm=2,gnh=7,rkmv-,pl=6,dknk-,ndn-,skvhb=7,vvv-,rv-,vdlc=2,tq-,qt-,jsmm-,lm-,sfxs-,gs=8,cz-,bc=8,qhk=7,tdszx-,zv-,nj=3,dknk=1,dh=1,bnnv-,pjz-,pt-,gnh-,tdj=7,pf=1,qtf=9,nxrq-,tdj-,hvd=6,bg-,rdpvp=9,sc-,mjv=4,bppqt=9,bhv-,pxc=8,rxscf=2,nm=7,hhj=9,vvb=1,vvv-,fhx-,hsqdlc=2,mk-,xgrpx-,bc-,rx-,nsqfv-,rn=5,jcbv=5,pjz-,hvfphq=7,mk=2,tgq-,dvp=6,jsr-,rh=6,xfm=9,bnnv-,tq=6,nhkd=4,qh-,hmk-,bhv=7,tdszx-,xb=8,tk=4,bzbcnx=6,bnnv=1,qh=5,zbpvbg-,crtj=8,tvf-,gqxd=9,hlkp-,vgtpp-,ck-,rkz-,htkdn-,mjv-,phz=9,dbr=7,dx=5,mpfqz=3,rf=9,nkpph-,rg=4,zrq-,rjlt-,dxjf-,zhr-,fqqcj-,zcg-,gb-,fjhp-,zld=8,cdpm=8,ht-,tq-,kg-,jbt=2,plz=5,tjtll-,cx-,ppfq=1,zd=3,mh=1,fq-,zvc=5,ptfb-,rknsq-,kdr=8,trpm=1,cgs=8,xsf=5,lksmk-,gs-,jp=5,zgt=7,pvz-,zgsf-,xxq=9,rx=2,nxrq-,dg=8,gg-,dfvld=3,cpllbj=2,dfvld-,dcnsc-,vl=7,jsr=8,rzh-,gft-,crtj-,hc-,sdh=1,txtq-,fgv-,nvt=6,hhlm-,jkkn=9,zll-,hvd-,qvv=5,cz=5,gdb=5,lr-,vgtpp-,njn-,ptfb-,bvr-,ppm=5,fqnrpd-,qvv-,ml-,cr-,bppqt-,bqc-,pdz=7,js-,fnpx-,lzz=4,mx=7,mh=1,gd=1,bvr=6,mkh=6,fgv=8,xpv=1,gvxx=3,xfm-,rrztg-,qq-,dfb=1,snfmr=4,jc-,fmbmb-,zpdc-,bt=5,bt=9,ddg=3,xz-,pdz-,rh-,lrmzj=7,fz=1,lkdppn-,sds=4,hsqgc-,jf=5,hxj=5,xhm-,lkdppn-,tq-,jcbv=7,kgp=8,phdz-,xhm-,pxc-,xsb-,hfg=7,jprr-,mkh=8,hksvq-,fqnrpd=9,dvp-,lvps-,jvs-,crtj=8,hfg=3,xsf-,mffn-,flp=7,zgsf-,bc=1,zcg-,xsb-,nl=4,kd=8,bc=2,brx=3,nhkd=6,vsh-,cc=1,fxq-,gd-,xxqp-,lp=6,nkk=2,bp=5,xpv=4,mldd=1,lj-,mdphr-,xz-,hkrpt-,kr-,ppm=6,mpg=3,xv-,qdxx-,th-,mkdgtg=1,qqfs-,nsqfv=1,fmbmb-,tb-,zv=7,ps=4,jln=8,jfddvv=4,nxrq=4,bbz-,jsr-,hlkp-,jsr=7,lsh-,nvt-,bc=3,xxq=6,dr-,hsqgc-,pjll-,qvl-,nl=8,hm=3,cjktk-,bkd=8,zgt=7,dh=4,mpg-,mp=9,gdcj-,clx-,tqrl-,vn=6,zzf-,kjfv-,xz-,bq-,kdr=2,bb-,nsl=1,fzd=9,flc-,ldx-,bmh-,hz-,tjtll-,tdszx-,pxc=3,qt-,lhj-,hhgpr-,xb-,jvzs-,fr-,vng=8,bbkn-,cspgj-,fdr=4,rjlt-,cdgl-,txtq=5,rknsq=1,drf-,hc-,lclc=6,zld-,mkz=9,nx=9,cdnv-,hhgpr-,vvb-,rbv-,vqm=1,zxb=3,nklhbp-,sdh-,nn=2,shxp-,xsf-,rx-,mz-,zcg-,fqnrpd=3,rkmv-,ndn-,nfhm=6,fkh-,kjfv-,hz=9,vh=9,phz=1,zqp-,ddg-,bg-,pm-,qv=3,fghlr=3,bt=1,mx=1,ll-,cx-,qvtp=2,rdpvp=2,tgq=3,dsd=9,fgv=1,hcm=7,sdh=2,bjk-,pc-,fcdh-,vng=9,jkb=3,sqbpg-,pljx=7,ps=4,vl-,sfp=9,gbf=4,qlznzq=6,zll-,mdm=6,zld=4,hz-,vsn=5,gzf-,hfg-,kdr-,sfp=2,pm-,qt=5,phz-,fmbmb-,xgghsn=7,kb=5,mqj-,dl=4,hkxl-,xp-,lp=3,dxjf=7,fgv=5,pl-,rzh=3,crtj=5,cd-,dg-,bhv=6,skg-,qbp-,vpcn-,hxx=5,ph=2,gnh=5,vj-,bkd=6,vmnkzj-,qtf=3,ddg=4,gvr-,nsl=7,vgtpp=5,xc=8,dcnm-,jc=6,kcv=6,vmcdl=2,cnf=8,rt-,hkt-,rg-,nsqfv-,zvcq=5,flp-,rkmv=7,mkz=8,gs-,slxx=7,rbm-,crlz=8,lr-,pn=4,vpcn=9,vj=6,lgzh-,xxqp-,rn-,cf=2,nn=2,bmh=2,bc-,fb=1,cz-,zjsj=5,dvbxgp-,jv-,zvcq=9,fk-,tq-,dfvld=9,tvdk=6,qv-,rzh=7,xz-,tvf=1,mdphr-,vh=6,tv=4,lrmzj=8,nxvzt=7,jsmm=3,kb=8,gfv=9,hhj-,ppfq-,clx=2,kgn-,sfxs-,nhkd-,tqrl-,qgcz=7,rzh=4,xhx=2,gg=1,fkh=1,mkz=5,kk=2,xsb=6,kn-,hmk=3,dg=5,jzn=7,tz=5,lclc-,qf=5,zd=4,xh=6,jcbv-,cd=3,rhk-,ppm=3,cdgl=1,qts-,jbr-,zvc-,brdf-,vrg=3,qbp=6,vn=7,dvp=6,ddg=4,gd-,jsmm=8,xjff=1,pvz=2,fc=4,fgv=3,zjsj-,bc-,xgghsn-,cg=2,zvc-,lp-,sfxs=8,ph-,grdj-,qs-,dzg-,bbz-,vpcn=6,lsh-,hr=2,th-,vmjs=8,tsl=2,xhm=5,mk=7,sdm-,cdz=7,vn=2,kjx=6,jc=2,mzp=7,gnh=9,tdszx=9,qs-,tq=3,hxj-,hcm=3,vpcn=8,ggp-,kgp=2,bq-,lc-,hlkp-,ppqqz-,hvfphq-,ck-,vql-,dcnsc=6,qmn-,tn-,rknsq-,lx-,brdf-,rf-,fp=8,jc=9,gvr-,nff-,bqc=1,qts-,rbv-,lzz-,vffmcp-,fnpx=4,hhgpr=1,cdpm-,qvv=7,vsh=4,zbpvbg-,jsmm-,gjb=1,ppqqz=3,kdr=3,msvg-,lc-,hlkp=8,hfl-,rkmv-,zhz-,jln=7,vdlc=7,xp-,snt=1,kjfv=4,gqxd-,hmk=4,qlb=8,rsbmsg-,xfm-,tv=3,rgpdf-,cdlvt-,sfp=6,dgc-,qlznzq-,pn-,mq-,rpz=9,mfh=1,dvbxgp-,cm=2,ck-,cd-,fqqcj=2,knf-,snt=5,zd-,xzs=6,zjsj-,czs=2,tb-,hlkp=6,rxz-,vdlc=1,lrmzj=7,qmn-,cf=1,vzlzvp=5,ppfq=7,vln=2,dx-,qgcz=4,hlkp-,bvr-,jkb=3,pp-,bvv-,fdmj-,frpn=7,frpn=2,jx=7,xsf=4,knf=4,cm=3,fc-,tcp-,xb-,mpfqz-,fkh=4,rkz-,jvzs-,lp-,vsn=7,hksvq=7,fdgdl=1,qmktt-,pm=5,dr=4,hr-,vln=9,hxfs-,ppfq=6,ls-,mdm-,kpsx=8,flp=4,ch=6,vrg-,bmh=4,mkh=8,ggp=1,zd-,hkxl=2,lr-,jrmv=2,lsxr-,jfddvv=1,mq-,kt-,kt=8,qscfz-,qsz-,pjll-,xh-,gdcj=1,rxscf-,cmxl=5,mzx=7,skg=9,nhm=4,rpz-,rzh=2,pvz-,bq=4,qh-,xx=6,dsj-,cr=6,ck=4,cdz=6,bx-,grdj=2,hxj=8,ts-,fcdh=9,hkt=7,zcg=4,lksmk-,gnh-,knf-,lksmk=8,sfxs-,hfl=3,rt=4,cvtl-,mqb-,bvr=4,zz=6,vmjs-,bvv=2,vvv=8,msvg-,cvtl-,sjg-,vdlc-,xb=9,bnnv=4,gd-,zvc=4,fz-,zxb-,nxvzt=2,hrkm-,mb=1,nks-,shxp=2,qvl=9,bjnm-,qtf=5,vcvc-,nxvzt=9,jmr=9,hxj=2,tz=9,jvs-,xgghsn=6,zvc=8,fnpx=5,vqm=7,dknk=1,mzx-,nsxcb-,sdm-,gnk-,mx=5,gbf-,gnk=4,rlh=2,gdb=7,mzx=2,bkd=6,hhgpr=3,dg=3,hr-,fhx=4,tjtll-,fc=2,gbxf=1,dzg-,hglsjv-,fk-,drf-,nklhbp=2,lhxfjx-,lzv-,cz=2,mqr=3,hpkxd=2,zgsf=9,dr-,bhv-,htkdn=4,pvz=1,rkmv-,fnpx-,jrp-,zgsf=7,sr-,zll-,tsl=5,bqc-,pgvxfc-,flc-,hvfphq-,dxr=6,kjk-,dxjf-,fcdh=7,qmn-,rrztg=3,rx-,sfxs=7,vg-,xd-,snfmr-,cz=9,zskc-,fhx=2,zhr-,hsqdlc-,gjdts-,bjnm-,dvbxgp-,nbn-,gjb=1,fqnrpd=2,jzn=1,rt-,jln=8,cgs=2,fkh-,flp-,hhj-,gbf-,djc-,bc-,rxz-,glk-,cjktk=3,gnhs=2,dstd=1,sdm-,mb-,ldx=5,cqdcxj-,cqdcxj=5,cvpv=8,dr-,kb=7,kjx-,kjk-,shxp=3,dxjf=9,xd=5,snt=1,dsd-,zgt-,bzs=5,nff=3,fqqcj=3,dvbxgp-,bc=1,fgc-,jrp-,dvlct-,bkd=2,qv-,vmcdl=1,mzp-,vj-,glk-,tq-,lzz=7,nvt-,hjq=6,sfxs=1,pm-,nsxcb=5,nklhbp-,lc=6,qgs=6,jsks=7,gjq-,dr=6,dfb=3,hhvx-,hglsjv-,tqrl-,vg=1,bb=8,xx=5,htkdn-,lsh-,xh-,msvg=1,rx-,skg=5,jvzs-,mqr-,lhj-,sfxs=2,zv-,dvp=1,lc-,qvl-,sm-,tvdk=6,rgpdf-,pjll-,rngnp-,vvv=5,gd-,kb-,lsxr-,pz-,rg=6,sdj-,lj=7,nhkd-,lzz-,bvj=5,mk-,dknk=1,mjvmqv-,cjktk=7,qts-,cr=8,cdgl-,rkz=4,cd=8,qsz-,hvfphq=7,tvf=1,dzg-,rkz=2,mdq-,bvj-,xjff-,mx=9,lhxfjx=7,nff-,jzn=5,jmr=4,frpn-,dvl=6,vdlc-,vl=7,rxz-,fr-,ch-,nn=6,gjq=8,mx=7,qbp=5,kb-,zrq=5,xp=6,mz-,nks-,qcj=6,sc-,pf=4,ppqqz-,njn-,tdk-,tvdk-,cmt=6,xgghsn=6,tb-,qvtp=6,fc-,lkdppn-,nk-,gjb=7,vdc-,zjhp-,cgs-,cx-,jv-,qgcz-,slxx-,jp=3,nm-,nl-,bjk-,xgghsn-,vvv-,hkrpt-,zqp=1,pjz=5,qgf-,xz=2,thf-,bbkn=4,ppfq-,njn-,xpv-,mz-,vvv-,fjhp-,hbrzc-,rlh-,xt-,hz=4,zld=5,cdlvt-,ttd-,ppfq=5,nsl=9,sfxs=2,dr-,jf=3,hbrzc-,fqqcj=5,qmktt-,snph-,cjktk-,hxj=1,skg-,msvg=2,pxc=4,hs-,skg-,qtf-,zd=1,zcg-,dl=9,nlkhc-,gd-,fs-,bkd-,lb=3,zvc-,pp-,hqnq=7,jcfdcg=4,qqfs=1,ppm-,gvxx=4,gb=4,thf=7,gqxd=3,bc=1,nj=6,nh-,zvcq=2,mjvmqv-,qrfh=6,bjnm=7,dq=8,xr-,lc=6,hhvx=8,gnhs-,tdj=5,zbpvbg=6,gfv-,fz-,qvl-,dsd=7,zqp-,zhr-,pvz=7,fkh=4,dknk=8,dvbxgp-,ptfb-,flc-,fghlr=7,hbrzc=3,rkz=1,ft=8,cz=8,nvt=5,drf-,hpkxd-,kb=8,dx=1,gjq-,kgn=9,cm=7,bzs=5,mdq-,ddg-,cz=3,nm-,pc=2,ph=3,sdh=7,dxr-,lzv-,lzz=4,kn=8,mx=2,lhxfjx-,xkt=7,sdm-,dgc=9,bvv=2,dbr=3,mdm=2,fq-,zqp=9,vsn-,zhr=9,bp=2,kgn-,nm=4,nbn-,tvf=5,xb-,plz=2,zvcq-,jvd-,qlb=9,qjdz=6,th=4,tk-,mpfqz-,nsxcb=8,pf=1,krcs-,tvf-,mj-,fq=4,lzv-,kpsx-,lsxr=8,knf=1,cdz=4,rzh-,cm-,sc-,bt-,rhk=4,qvl=9,jsmm-,bqg-,mjvmqv=9,rj-,kn-,htkdn-,kgp=5,ftfl-,vpcn-,hnxt=5,fk=1,skg-,vzlzvp-,xz-,nks=4,rrztg=2,fmbmb=6,bp-,js=1,zqp=8,ls=6,qsz-,tq=9,nfhm-,gnh=7,fxq=3,zjhp-,dsj=1,dvp-,bqg=7,krcs=9,qts-,vgq-,mqb=8,zskc=8,xsb=4,jsr=7,nj-,jbr=8,crlz=9,fkh-,tdk-,skvhb=6,cvpv-,xxpb=1,gqxd-,gnk-,pn=1,dcnm=7,qvtp=4,jbr=1,cmt=3,kr=3,vh-,xd=1,sppp=4,cgl=1,kk=4,tv=6,vmjs=4,xx=2,gft=9,xjff-,krcs-,cg-,zjsj-,dfvld=7,fb=3,zll=9,dvbxgp-,nm=8,hsqgc-,grdj-,qscfz-,ndn=8,tf-,fdmj=4,cgl=1,ndn-,gb-,hfg=7,hbrzc=2,gdb-,rqj-,mkz=7,nfhm=7,pjll-,lhxfjx-,hnxt-,bmh-,kk=9,xxpb-,hbrzc-,kgp-,qtf=6,rdpvp-,hvfphq=2,zgsf=1,xxq=2,dfb-,zv-,cr-,frpn-,fd=7,kjfv-,hsqdlc=2,xr=7,sp=7,qdxx=2,tdk=5,tvdk-,phz-,nsxcb-,tv=4,vqm=7,ndn-,qrfh=5,cdz-,dgc=7,qbp=2,pvz=8,pm=8,hvfphq=6,ddg=5,bvr-,gjdts-,jrmv-,bvr-,mp=2,dzg=2,nlkhc-,frpn=5,hpkxd-,dxr=7,vl-,qpz-,zhz-,kc-,ndn-,lgzh-,kd=4,lhxfjx=7,fhx-,snfmr-,zld=8,smlh=8,vph-,hlkp=6,lkdppn-,gg=5,fkh=7,pn=8,rn-,hlkp=6,hpkxd=5,bmh=2,xhx-,hnxt-,fd-,dqsx=2,rgpdf-,jm=6,cc=6,xkt-,tk-,jvs=1,kpsx=2,zpdc=1,nvt=1,fdgdl=2,qpz=7,bqg-,bbkn=9,tb=7,frpn=5,vgtpp=3,hxfs=1,ch-,xpv=3,rx-,gs=1,dxr-,bh=2,jsks-,zz-,kpsx-,cf-,xz=4,rh-,dxjf=3,pl-,qvtp-,fgv-,mjv-,vj-,rngnp=8,mqj-,hhvx-,qbm=7,lsxr=4,lc=9,sdj=5,dfvld=8,lclc=4,fq-,xxq-,jc-,hfl=3,gb=9,ppfq-,zxb-,qbm-,pl=4,spb-,xzs=9,mjv=9,hmk-,dg=2,pgvxfc-,gdcj-,qmktt-,cqdcxj-,vg=2,hz=7,xgrpx-,nj=2,gnh=8,dstd-,rxz-,hkrpt=9,bb-,qvl=9,pvtk=1,nklhbp=5,kd-,mzx=4,xxqp=8,rpz-,fc-,kb=1,hxfs=6,qvv-,cck-,ppm-,ppfq=9,pfp=6,xc=2,dg=8,fdgdl=8,fdgdl-,vph-,fz=8,dxr-,fr=9,grdj-,ggp=9,tsl-,hc=9,vdlc-,sfxs=1,mkh-,qmn=8,cdlvt=6,ppqqz=8,cmt-,cmt=8,vpvlq=8,vzlzvp=1,nhkd=7,jvs-,zv-,bzbcnx=1,cspgj=6,rrztg-,rkmv-,bt=8,lb-,vl=9,zhr=1,js-,cg-,dvp=7,vvb=9,pl=6,lzz-,zbpvbg-,rsbmsg-,vmjs-,hkrpt-,bbkn=6,hmk-,bjk=9,zcb=8,pf=7,nklhbp=5,lp=5,lvps-,lsx=9,jkb=3,dx-,xsb-,qbm-,bbvt=9,ch-,cgl=4,bhv=9,vl=3,dsd-,flc-,mnf=9,jln=9,mjv=7,jsks=9,qmn=2,lcbf=6,mpg-,hmk-,nsqfv=9,bzbcnx-,cdpm-,ftfl=9,nfhm=5,jsmm=5,flp-,ph=9,hhvx-,qf-,mxbfd=6,gjq=6,nbn-,nks-,rj-,hvfphq=2,lx-,vmcdl-,mmt=2,jp=2,rlh-,gzf=2,msk-,xkt=9,nfhm=1,vmjs=7,fdmj=8,mk=6,pvz-,snph-,lclc-,qrfh=8,tsl=5,zskc-,xsb=2,vm=7,vffmcp=5,lhj-,qbm=5,trpm=3,qmn-,sl-,ddg-,kcv=5,cdnv-,nvt-,vm=2,qcj-,ggp=5,qlznzq-,dfvld-,cm-,mkz=5,hpkxd=9,pl=5,zbpvbg-,phdz-,xzs=6,hmk-,gnk=4,lk-,gbf-,cc=3,gvxx-,rxscf=4,hcm-,fhx-,kt-,cgl-,lhxfjx=6,cz=5,slxx=9,gjdts=7,tjtll-,ppfq-,kk-,mk-,qdmgv=3,hsqgc-,bx-,qt=2,czs=7,snph-,sdm=1,mkh-,qqfs=8,glk-,cmt=2,pfp=4,vpcn=8,hm-,lr=9,mjv=9,tb-,gjb=1,sdm-,ggp=5,lc-,mhhvcd-,slxx-,mx=4,cz-,ppm=2,hvfphq-,flc=4,shxp-,zjsj-,ppqqz=1,jlx=9,djc=6,tq=2,mk-,sfp=7,dcnm-,nsxcb=3,kr=5,gs-,cgs-,jvs=4,fc=5,pvz-,fz-,lk=3,gvxx=5,mq-,qhk=2,mldd=8,fghlr-,pxc-,kk=6,hkrpt=3,gft=4,jkkn=5,fgv=5,zj=1,vql=4,ppfq=5,gqxd-,sbz-,rhk-,bxq-,cmxl=9,hs=7,vj-,qlb-,fz-,sr-,cdnv=6,rknsq=7,nk-,nkk=4,qvv-,rhk=3,tdszx=6,cdnv=4,dknk=4,jvzs-,rbm-,htkdn=6,mjvmqv=6,dfb=7,thf=8,xc=5,fzd=9,qxjvvt-,zbpvbg-,bbkn=1,hs-,mkdgtg=1,sbz=1,pvz-,hc=5,lgzh=5,gnhs-,cdpm-,flc-,gvr=5,fdr-,jkb=7,mffn=6,vcvc=2,xp-,cmxl=1,plz-,jkb-,tdk-,jvd-,qrfh-,qgf-,vph=9,sdb-,smlh-,nlkhc-,mj=9,lr=8,cm=5,kg-,rrztg=3,hc-,jf=9,tz-,qvv=7,cnf-,hhlm=6,sqbpg-,zz=2,vm-,cnf-,lk-,fdgdl-,nsl-,mdm-,qsz=3,txtq=5,vdc-,vzlzvp=1,djc=6,ldx-,cr=2,kjk=3,bqg-,ch-,sjg=3,tk=4,jsr-,frpn=9,cdgl=6,cr-,dfvld-,pvtk=7,nj-,mxbfd-,jm-,bmh=8,vn=1,fgc=1,dx-,skvhb-,qpz-,bhv-,kpsx=9,bzbcnx-,clx=3,zgt-,kjfv-,xhm=7,xd-,ts=5,cnf-,bjk=3,sc-,dvl-,zv=1,qlznzq-,fdr-,zgsf=2,crtj=8,pljx-,zj-,cr=7,mh=4,xc=3,zll-,dgc-,vffmcp=5,dknk=1,snt-,lsh=3,lhxfjx-,vvv-,nvt=8,qjdz=2,xhm-,vph=8,bt=1,pn=4,plz=3,dh=8,hkrpt-,xt=4,cvpv-,gg-,cmt-,phz=1,zgt=2,qts=3,zll-,tz-,cnf=3,lzz-,qhk=6,hpkxd-,hhj=7,bp-,mdphr-,ttd=3,vsh=6,jlx-,fk=4,sgp-,fsps=2,cjktk-,bjk=3,tk-,lcbf=6,cd=5,zzf-,zxb=8,pxc-,fb-,sn=6,hs-,nff=3,jf-,phdz-,gqxd=1,rrztg-,kdr-,ppm=6,sm=1,fp-,fdr=7,fxq-,hsqgc=1,gbxf-,lp-,gnhs=9,shxp=3,mkz=6,mb-,mdq-,fsps=9,lzv=6,qv-,rv=2,qpz=2,mdm=5,vvv-,zgt-,lzz-,jcbv=9,ps=2,rjlt-,bppqt-,sx=1,rn-,hxfs-,vsn=5,jx=1,fsps=9,zv-,sn=1,zcb=5,jfddvv=9,xr=6,cg=4,fz=3,kjx-,zjhp-,tz=2,cgs=4,kn-,hkt-,lc-,tz=5,sp=4,jkkn=5,rgpdf-,qdxx=5,ppm=5,qmn-,dvp-,jvs-,ps=6,zbpvbg-,tcp=7,jkb=4,xxq-,tgq-,rt=2,bp=4,rxscf-,tdszx-,lrmzj=7,hr=9,vvb=6,mqb=2,thf=4,hhgpr-,fr=8,nks-,glk=6,bjnm=1,hglsjv-,qgf=2,rsbmsg=3,sl-,qlznzq-,jmr=3,sp-,vvv-,vpcn-,vng=1,rpz=7,hnxt-,vng-,vj=4,dzg=5,zd-,dxr=2,sfxs=9,hkrpt=1,gdcj=5,dxjf-,vmcdl=9,vg-,xd-,mqb-,dfb=9,hxfs-,dgc=5,rtn-,lgzh-,lvps=2,mjvmqv=7,hhgpr-,zc=2,qvl-,jrmv=8,tjtll=4,xsb-,rsbmsg-,knf-,hhj=3,dzg=8,ppqqz=4,zcg=2,tf-,mz=3,bx-,skg=7,gbxf=1,rpz-,dcnm=6,cdpm=2,mjvmqv-,jl-,cnf=1,tk=5,mdm=7,cpllbj=5,vql-,dcnsc=6,sjg-,tvf=8,txtq=8,lr-,sml-,pjll-,bqc=8,ls-,rj=9,cg-,cmt-,nsxcb=9,pm=4,jv=1,pn=3,hksvq=1,ph-,sqbpg=7,pf-,bnnv=2,gjq=9,fcdh-,fqnrpd-,jsr-,hbrzc=1,plz=1,kn-,pl-,xxqp-,bzbcnx=6,kgp-,zcg-,bgqlk-,pjll-,ptfb-,jsmm-,dcnsc=8,vh-,hhvx=6,mhhvcd=2,dfvld-,zcb-,bzbcnx-,jln-,bvv=3,djc-,jvd=1,hmk=9,clkg-,mz=4,kt-,bbvt=9,dvl-,mpfqz-,ndn-,nbn=9,ttd=1,zgsf-,qsz=2,sjg=2,ft=4,lsh-,hhgpr-,crtj=1,mfh-,krcs-,lhj=7,sfp-,dfvld-,txtq-,ps-,rkz-,lr-,czs=4,pc-,mpg-,dsj-,gjdts-,ptfb-,sp-,mldd=8,bzs=4,bzs=9,fp-,sn-,fdmj=2,skvhb-,gvr-,cgl-,fc-,fdmj=6,bgqlk=7,nm=6,jprr-,msk-,nj=2,kg-,vn-,tn=5,bppqt-,sx-,qmn=7,hbrzc=7,rpz=8,nsl-,sdh-,vvb-,xgghsn=9,ptfb-,kpsx-,brdf=1,qdmgv-,sjg=1,hnxt=5,slxx-,knf=8,cdlvt=4,rjlt=4,pz=2,glk-,tsl-,djc-,vdlc=6,mdphr-,hfl-,thf=3,sm=3,xgrpx=2,cdpm=5,sz-,sz-,xhx=7,kn-,bbvt=6,ml=1,rt=8,rrztg-,kt=7,xz=9,bg=8,brx=9,qpz=2,zj-,lhj=4,mqj-,mjvmqv=7,mjv=3,jrmv-,dknk-,lclc=5,dxjf-,fdmj=9,xd=4,tdk-,lksmk=5,bzs=8,lkdppn=5,gft=9,rt=7,xxq-,hhj=4,fqnrpd=1,dxjf-,nsqfv=1,bqc-,fc=4,nbn=1,vph=1,zv=6,phz=8,lksmk-,qbm-,jcfdcg=5,tdk-,rgpdf-,sm=8,qgf-,djc=7,kgp=3,gnk=9,rjlt-,djc=7,xxpb=1,dknk=8,krcs=5,qq=6,dfvld-,cdlvt=2,bc-,sfp-,kjfv=3,mhhvcd-,mx-,cz-,tv-,sqbpg-,zrq=6,fgc-,ndn=3,dr-,gvxx-,rn=9,fc=6,frpn-,cgl=8,hhgpr=9,jrmv-,ck=6,qdxx=8,pgvxfc-,fp=8,gfv-,hz-,cr-,cpllbj=7,dl=7,cz-,hqnq-,xxpb-,hhvx-,mz-,vcvc=7,vm=9,qjdz=8,qv=6,bp=2,qqfs=9,gqxd=6,htkdn=1,xgghsn-,lzz=8,qv-,fghlr=1,zgt=6,kb=8,lx-,th-,snt=7,qts=7,jsks-,zqp=5,shxp=4,plz-,xx=1,cz=3,jmr-,vn=7,bjk=3,mjv-,rkz-,xpv-,cdpm-,lr-,vrg-,pz-,rf=8,lkdppn=4,fc-,ht=8,gjdts-,xr=9,fk=3,gfv-,slxx-,kjk-,ml-,ndn-,pl=3,cpllbj-,fdr=8,dfvld-,qvtp=9,sdj=9,mmt-,bqc-,mqj=4,rgpdf=8,pvz=1,lj-,tqrl=3,dgc=6,sz=1,sfp=6,zjhp=7,qt=9,tcp=3,qrfh=6,lhxfjx=1,bbvt-,rxz-,mfh=9,mh-,vzlzvp=4,zc-,rbm-,ftfl-,gjq=9,sr=6,mq=8,hhlm-,vh-,hsqdlc=2,tv=7,kpsx-,rknsq-,kk=5,ddg-,bjnm-,txtq=1,dstd-,tvdk=6,qvv-,cnf-,mzx=3,hksvq-,lp-,tdszx-,fhx=1,fdgdl=9,dx=4,zll-,snfmr=9,qts=2,rxz-,kb=1,pvtk-,dstd=5,dsd=5,jrp-,xt-,tk-,bjnm=9,cck-,nl-,xc=9,xhx=9,hpkxd-,kjx=6,dzg=2,zvc-,mldd=4,gnk-,pljx=8,nkpph=8,kg=8,phdz=2,vng-,mpg-,bb-,fgv-,bg=7,pm=8,mnf-,cdnv-,mkh-,fz-,shxp-,cgl-,tvdk=2,cdnv-,dvlct-,lb=6,zxb-,ndn=8,qlb=9,fzd-,zpdc=2,cck-,fq=3,qgcz-,lsxr=3,vn-,fz-,sm-,mdq=5,smlh=7,cmxl=3,ph-,tdj=1,rtn=9,pjz=5,fxq-,qcj-,kk-,kgp=7,kk=4,ldx-,msvg-,sp-,vn=3,zjsj=1,gnhs-,qpz=9,dsj-,nm-,qgf-,xhx=2,jlx=2,nff=5,fq-,pvz=5,vln-,ptfb-,jrp=9,tdszx=9,sp-,lcbf=8,qf=3,gqxd-,qgcz-,jcbv-,bnnv-,bt-,fsps-,bx-,kjx=8,tsl=2,hnxt=5,vpvlq=7,mpfqz-,jbt-,ft-,mp=4,vmcdl-,zxb-,rh=3,brdf-,mfh=9,tdszx-,vzlzvp-,gfv-,mzx=5,qcj-,hksvq=1,pz-,kt=6,xc-,jsks=3,gnhs-,rknsq-,lx=7,mb-,cc=1,nk-,zrq=4,vpvlq=8,fqqcj-,vl-,rhk-,xxpb=8,kr-,bp=9,nbn=5,qq=8,qvv=2,bq=7,lp-,jrmv-,zcc=4,xxpb-,krcs=8,hhj=4,tn=6,plz=5,gbxf-,bjnm=3,nks=3,kc-,vmjs-,gzf=4,fz=6,gqxd-,ftfl-,hxj=9,zcc=6,xc-,vph-,brx-,qvl-,gd=6,jmr=5,nkpph=6,brx-,qmktt-,rngnp-,lj=9,pvz=5,kk=6,tdj=7,bbz=4,cpllbj=6,qscfz=4,qlb=4,sbz=4,fc-,lhj-,rlh=1,tz-,zpdc-,tvdk=1,xpv-,skg=1,bvj-,sl=8,tb-,kgn-,spb=1,fdmj-,xzs=4,hxfs-,fsps-,bgqlk-,vdlc=7,sc=1,cf-,vh=4,mk=3,ch=4,nx-,cz=8,gdcj=6,mx=8,kd=1,zskc=1,skg=2,zzf=9,vzlzvp-,jzn-,zld-,gb-,lr=2,krcs=8,lx=2,bbvt=4,dvp-,dvl-,bjk=7,vdc=7,qf=6,qtf=4,pt=9,bjk-,dstd=6,xh=5,kgp=5,xgghsn=2,vh-,cg-,sm-,kjx=7,vvb=2,rt-,nks=3,kgp-,nxrq=5,dvlct-,mpfqz=2,gnhs-,cdnv-,xfm-,vmcdl-,fgc=1,nsxcb-,pf=2,mkh-,zj=8,fxq=8,pjz-,hxfs-,xgrpx-,rkmv-,xfm-,mx-,jvd-,bp=7,fcdh=8,mqb-,tjtll=7,mmt=3,kgp=3,qmn=3,rbm-,nlkhc=8,hcm=4,ndn=1,jrmv=8,gnhs-,hkrpt-,smlh-,vm-,gd-,shxp-,jkb=9,xv-,mjvmqv=1,rx-,lksmk-,rxscf-,qgs-,crtj-,tb-,tvdk-,sbz=4,bbz-,cmt-,xjff-,xd=5,hcm=1,xsf-,rg-,snph=4,rf=9,xb-,hpkxd-,vdc=1,pl=8,tvdk=1,ps-,zcb-,glk-,vdc=2,fb-,zc-,bc=1,cm-,cx-,dh-,fxq=9,ft=4,rx=5,np=4,rqj-,lp-,cz-,gs-,gg-,nkpph=2,zrq-,nks-,fqqcj=8,vg-,ck=2,nl=1,fb=5,kdr-,mx=8,ggp=4,hhvx=6,vvv-,qhk=4,jsmm-,zgt-,kd-,mzx-,rx-,hkxl-,ht=9,lm-,hhvx-,xb-,zj-,cc-,vdc=3,qpz=6,kg-,bvv-,dknk=7,vm-,pvtk=9,fkh-,fxq-,cmt-,hlkp-,xxpb=9,gnk-,jprr-,sr-,dxr=3,zc-,hmk-,thf=9,htkdn=9,np=9,zqp-,lzv=7,sfxs=2,cr=2,bvv=8,ts=3,vl=1,njn=3,gnk=6,ch=2,vph-,ndn=7,vn-,pp-,nsqfv-,hs-,tdj-,sx-,cdgl-,dfb=5,lp-,lvps-,bvj-,rgpdf=7,vffmcp=2,dvl=1,fdr=8,pp-,qt-,qvv=3,dzg-,lp-,vpvlq-,hkxl=9,cm=1,sdm=1,pjz=6,ts=2,zrq=2,dvp=7,pp=8,tcp-,phz=1,nxrq=8,ls-,xjff-,jv-,cvtl-,gvr=8,sc-,mkh=1,kd=4,hsqdlc-,fsps-,mldd=7,sc=8,qv-,gbf=1,njn-,mzp=9,hvfphq-,bvj-,spb=7,gbf-,lhj-,fdmj=8,jl-,mfh=8,tdj=8,cjktk=9,vqm-,jsmm-,cck=7,ldx-,nh=2,hc=6,rtn=3,cz-,rtn=7,qmn-,zz-,tf=8,hxx-,ppfq-,qqfs-,cm-,bbkn=3,pvtk=7,zrq-,cmxl=1,hmk=9,xzs-,cdnv-,cmt=8,sr=2,jp=6,cc=7,lsh=5,cf=7,hc-,jfddvv-,flc-,fhx-,knf-,vh=2,zv-,jcbv=4,cmt=8,jvzs=5,nbn-,jcfdcg-,glk-,zvc=2,sdh=6,ptfb=9,rbm-,fc=9,jm=1,fsps=5,gbf=7,jprr=7,jvs-,hr-,clkg=5,vqm-,rn-,lkdppn-,hvd-,ps-,qpz-,dl=8,xkt-,cdz=7,vsn=9,nvt-,ch=1,krcs-,nsqfv-,rlh-,cmt-,mh=3,xh-,pfp=9,xfm-,smlh=3,rv=1,czs=2,tvdk-,msvg=3,snfmr-,bmh-,xgghsn-,lvps-,gb-,nh=4,gjdts-,hs-,fnpx=5,kpsx-,spb-,np-,bbvt-,pvz=4,vpvlq-,dstd=5,fc=6,bq=3,rzh=8,fghlr=5,ts-,hsqgc=5,tb-,fzd-,jrp-,vl=3,dstd-,zjsj=1,dvp-,jx=3,ltlbm-,lhj-,zpdc-,sjg=2,lvps-,dx=6,fz-,hpkxd=5,xhm=9,zd-,msvg=7,hhvx=4,tdj=6,bg=1,kc-,bb-,fq-,bvv-,cnf-,ph-,jrp-,sc-,frpn-,jbr=3,bqg=8,xkt-,nkk-,kjk-,dg-,hr=3,plz-,nj-,ls-,bgqlk-,tz-,fz-,xgrpx=2,jzn-,gdb-,kg-,kcv=1,sdb-,hqnq-,np=5,kjk=3,hs-,nl-,fxq=2,rxz=5,bb-,hfl-,zbpvbg-,pm-,fgv=9,kdr-,sml-,zbpvbg=7,bzs=4,pl-,rqj-,sds=9,skg=6,fd=5,ck=6,zd-,pjz-,sdm=3,jprr=7,jcbv=8,vdlc-,mfh-,fdmj-,hkrpt=6,kb=4,cmxl=7,gzf=2,cd-,bzbcnx=9,tcp=3,hz=6,mh-,cdgl-,vg=6,fghlr-,cd-,fghlr=1,cx=5,lsh=2,rpz=7,bx-,nkk=3,clkg=8,qq-,jp-,kcv-,fp=3,gtvh-,xh=1,vl-,xd=8,mp-,msk-,mqr-,hjq-,tq=6,gvr-,jcbv=5,xsf=9,dr-,jvd-,mhhvcd=6,hxfs=6,nlkhc-,lrmzj-,jrmv-,jrp-,dsj=6,kgp=1,hxx-,fz=6,zjhp=4,gb-,shxp=9,ptfb-,ck-,mffn-,tq-,jvs-,bg-,kr-,pf=4,fqnrpd=7,sfxs-,vdc=1,mfh=3,qs=7,rj=4,fp-,lhxfjx=2,fp=5,jsmm-,lc=6,qmktt=5,cdlvt-,tf-,bbkn-,qrfh=1,nh=7,xt-,snfmr-,xp-,lk=1,mkdgtg-,cmxl-,sdb=4,rzh-,xx=2,fs-,ddg=1,fhx=3,qxjvvt-,gjq=2,dvbxgp=7,xt=7,gqxd-,zpdc-,zskc=5,ftfl-,ts-,fr-,mhhvcd=3,mjvmqv-,mj=3,cd=4,kjk-,mffn=9,nsqfv=2,cdgl=4,gfv-,lsx=3,clkg=3,mldd-,mkz-,rxscf=6,ggp=8,cg-,rngnp=9,dcnm-,tvf=6,cc=5,jx=6,jl-,plz-,pl=7,zld=8,fghlr=8,dqsx=5,mz-,lx=5,tgq-,zcb=6,fqnrpd-,dl=6,bc-,zcg-,cvtl-,kc-,nxrq-,gjq=3,hxj=4,rn=5,vl=3,pz=3,xsb-,pjz=7,hhj-,vcvc=9,bjk=4,qsz=7,djc-,xr=6,ph-,qlb=4,pf=5,skvhb=7,fnpx=7,vng=8,krcs=7,xhm=2,mkdgtg=2,trpm-,zpdc=6,lhj-,vph=3,jm=2,bjnm=4,dl=6,gg-,hglsjv=2,tcp-,pl=6,lx-,dr-,zzf-,czs=2,nsxcb-,qvl=5,tk-,hglsjv=6,jvd=3,xsf-,dr-,rn=7,jrmv=7,rt=9,dgc-,jkkn=7,sdm-,rsbmsg=4,dknk=4,gjb=6,pc-,lr-,nxrq-,sjg=8,cz-,thf=3,rqj=2,dxr=6,kgp-,pvz=5,rlh-,zbpvbg=4,jrp=6,fghlr=7,lhj=8,mkdgtg=2,dh=5,ts=9,gdb=5,grdj-,rt=7,bjnm-,gfv=5,mpfqz-,knf-,xv=2,xx-,sr=4,mffn=2,sdj=8,kt-,phdz=3,cgs=1,qbm=5,gbf=2,zrq-,zll=7,nklhbp-,bqc-,lc=9,sdb=4,bzbcnx=2,dh-,cdz=5,js-,hs=3,ls-,bg-,mj-,gfv=9,sp-,dl-,rdpvp=7,gjb-,xr=4,nlkhc=7,lb=3,cdz=8,gjq-,bbkn=6,kgn=9,tf=2,hrkm=4,rxscf=6,dfvld-,jcfdcg=4,zbpvbg-,vdlc=2,xgghsn=7,ts-,xt=9,hsqgc=4,jm=3,xx-,rtn-,pgvxfc=8,qt=5,mffn-,vj=1,sfxs-,qscfz=9,mk-,xpv-,ggp-,ptfb=2,vgq-,gg=4,dcnsc=1,clx=8,mfh=7,lp=3,ch=6,qbp-,flp=2,nxrq-,nvt=7,nlkhc=2,bvv=2,dg=4,xkt-,cc-,gzf=6,xfm-,rbm-,clx-,rdpvp=7,lzz-,sqbpg-,grdj=8,js=9,pp-,vcvc=3,gb-,pdz-,drf-,phz-,mzx=6,pf-,tdj=1,pjz-,rxscf=7,fzd-,qqfs-,cvtl=3,rtn=6,nks=3,vgq=3,bxq-,pdz=6,qgs-,kcv=9,nj=6,frpn=4,bt-,sqbpg=6,zcg-,mq=5,hrkm-,lkdppn=1,vffmcp=2,hsqgc-,ttd=5,fk=8,zxb-,grdj-,kjx=5,msvg-,vmnkzj=5,cc=2,fzd-,pz=6,xzs-,bkd-,bvv-,msvg=5,qqfs=6,ndn-,sds=9,mdphr=1,jzn=6,gjdts-,qq=4,rrztg=5,mdphr-,xhx-,hsqdlc-,vsh-,vqm=7,tvdk-,pjll-,smlh-,jrmv-,nk=4,fdmj=3,tz-,trpm=6,sr=2,lb-,cgl-,flc=3,sqbpg=3,drf-,qv-,hpkxd-,xxq=8,kjk=2,zpdc-,mqb-,ggp-,lzz-,pjll=5,tq=2,fdgdl-,cdpm=2,smlh=2,dx-,cmxl-,mq=1,zqp=5,kgp-,qmktt=4,xzs-,gqxd-,msk-,xp-,rsbmsg-,sdh-,hjq=8,vffmcp-,fzd-,vdc=4,kc-,sbz=2,bp=7,hbrzc-,bh=7,sds-,hkrpt=6,nsl-,mqj-,cdlvt=1,mp=7,lzv-,dvbxgp-,hhvx=7,bvj=4,xsb=8,bp-,xc-,xxq=3,dg-,mzp-,kgp-,zhr=4,qh-,xgghsn-,ltlbm=9,dbr-,qf=3,cdpm-,cd-,jsks-,fdr=6,mh-,cspgj=7,gjdts=2,vql=4,fkh-,vgtpp=9,gdcj-,tq=3,brdf-,fd=3,qbp=8,mfh=6,dstd-,gdcj=6,dfb=3,gvxx=3,qtf-,tdk=1,hm-,nvt=7,qtf=8,jf=8,fd=4,rg-,zrq-,jcfdcg=3,tn=1,vmjs-,dfb=9,pvtk-,sbz=8,qq=9,lp=9,vmjs-,tv=7,hfg-,ck=1,vgtpp-,cd=3,brdf=2,rtn-,jfddvv=2,vql-,zxb-,qlb=7,mjv=6,ll-,sjg-,qqfs=1,hkt-,gtvh-,plz=5,rx=7,mb-,xh=1,skvhb=1,sp=9,vl-,rf-,nhkd-,rf-,xr=4,cdpm=8,pn-,cg-,mz-,brdf-,rx-,vcvc=3,gfv-,xjff=8,bbz=1,mqr-,zvcq-,dzg-,dbr-,gd=4,fk-,fgv-,vgq-,vvv-,jkkn-,rhk-,hhgpr-,htkdn=8,bjnm-,tq-,mpfqz-,slxx=8,jprr-,qt=5,tn-,xz-,zj-,dvbxgp-,sfp=4,rr-,hksvq=7,ggp-,mpg-,dgc-,mkz-,fs-,bjnm=9,hmk=2,xzs-,ck=1,cdgl-,fnpx=5,fxq-,thf-,pjll-,cdz=2,hr-,cgs-,vvv=7,fdmj=2,hkrpt-,lb-,bnnv=1,hvd-,gjb-,cm-,tsl=9,qvv-,trpm-,fqqcj=5,lm=6,hkxl=3,vmcdl-,hqnq-,njn=5,xx=1,pvtk=4,lc-,ppfq-,jx-,vpcn=7,lhj-,ndn=8,lm=9,cpllbj-,mmt-,krcs=8,tvdk-,ph-,nklhbp-,cz=7,lksmk=5,xxqp=4,zv-,tz-,lc-,nkpph=2,zld=3,tvdk-,kpsx-,zvc-,bnnv-,rj-,jzn=5,nvt-,cgl=4,pjz-,gvr-,jvd-,bc-,dvlct=2,jlx=4,zhr=8,mhhvcd-,fqnrpd=3,mqb=2,pjll-,skvhb-,kr=1,rpz=2,vsh-,bbvt-,mxbfd-,sz=1,njn-,txtq=7,jcbv-,sfxs-,jprr=7,dxjf-,sc-,vg=7,jzn-,dstd=5,bvr-,skvhb-,qhk=8,jm-,qcj=2,mpfqz-,zgsf-,xgghsn-,rx=7,fq-,nvt=1,lx=9,sdh-,mzx-,bc=6,ft=8,dh=3,jl-,rf=4,gjb=5,gnk=6,cr-,dq=6,zjsj=1,vmnkzj-,cmxl=1,rpz=9,qvv-,zj=5,tgq-,pljx-,kgn=1,pc=9,lsx-,nbn=3,cvpv-,xgghsn-,tf-,rbv-,nfhm=3,hksvq=2,lc=5,djc=6,zd-,dbr=8,pvz=9,kd-,cc=8,qbp=2,dl=4,nsqfv=9,sc-,rbv-,bqc=2,vgq=4,fd=4,xxqp=1,lrmzj=7,vg=7,xt=3,hkrpt-,cx=2,cgs=1,fc=1,nklhbp-,zrq=7,jbr-,cm-,sc=9,ftfl-,hz=9,bppqt=5,fhx-,lp-,xh-,mpfqz=2,cgl=7,sc-,xp-,nlkhc=8,sz-,bvv=8,mdphr-,rqj-,vgq-,xhm=4,vgq=6,cdgl-,vmcdl-,rjlt-,msvg-,dsd-,cf=7,ll=6,fhx-,vzlzvp=7,snfmr-,bzs=5,mq=3,lj-,kpsx=2,rlh=2,mpfqz=2,rgpdf-,xsb=6,ck-,mhhvcd-,nm=1,gvxx=5,fzd-,jl=5,pjll-,tvdk=8,cdgl=6,jv-,kg=1,bqc=5,bb-,hc-,rtn-,qgf=6,qh-,pp=7,tdj-,xx=5,jln-,zld=2,ck-,cspgj=5,lp=4,zv=3,kpsx-,cg=2,ht-,fgv=6,jvd-,tv-,hfl-,cdlvt-,tdj=2,knf=6,xt-,gbxf=6,bxq-,zxb=7,grdj-,mqr-,zzf-,xv-,sm-,fgv=3,xh-,lzz=3,sn-,qmn=8,fr=4,tsl-,vrg=7,zhz-,cgs=6,hfg=8,bppqt=5,xgghsn-,lzz-,qtf-,nm-,lhxfjx-,pz=8,xsb-,vln=2,qs=6,dxr-,sdh=9,lsh-,lb-,kk-,xr=8,jf=6,cmt=2,bq-,rj=2,jx=5,rbm-,bqc=5,sml=2,ptfb=9,cjktk-,zrq-,jkkn=9,bg-,rgpdf=7,cm=7,vmjs=7,vpcn=7,clx-,hksvq=7,cqdcxj-,dknk=2,gft=4,gzf=8,qqfs-,qts-,qvtp=1,mb-,fk=8,rj=9,gvr=4,qt=7,dvl-,zcg=7,ppqqz=9,mfh=9,rlh-,hxx=9,cvtl-,hlkp-,gjb-,msvg-,rr=8,jl=2,sx=9,mjvmqv-,fb-,zcb=7,jsks=1,lzv=1,sbz-,gjb=6,jkb-,cg=9,rpz-,np=1,vpvlq-,hhlm-,bq=5,zvc-,rj=7,lk-,gvxx-,hjq=5,lj=9,zv=3,cpllbj=9,bqc-,fk=5,zcc-,vqm-,sdm-,nvt=3,sbz-,tk-,hvd-,ppfq=4,tqrl-,cgl-,fqnrpd-,bp-,ggp=1,qjdz-,tqrl-,hkrpt=3,tb=2,cmt=2,kk=3,kpsx=3,pfp-,bqc=2,cx=6,qdmgv=2,vgtpp=2,ch-,snph-,cvtl=7,zxb-,bmh=1,gnk=7,rg=5,tjtll-,ggp-,shxp=5,vng-,pgvxfc-,jcbv-,bgqlk-,pvz-,qtf=4,vffmcp-
"""
)

