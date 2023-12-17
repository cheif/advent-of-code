import Foundation
import Shared

private struct State: Hashable {
    let position: Position
    let direction: Direction
}

public let day17 = Solution(
    part1: { input in
        let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { Int(String($0))! }})
        let end = Position(x: grid.xRange.upperBound, y: grid.yRange.upperBound)
        let start = State(position: .init(x: 0, y: 0), direction: .right)
        let best: [State] = aStar(
            start: start,
            finished: { $0.position == end },
            estimatedCostToFinish: { $0.position.distance(to: end) },
            candidates: { state in
                let positions = (1...3).compactMap { steps -> (Position, Int)? in
                    let position = state.position.move(in: state.direction, step: steps)
                    guard grid.positions.contains(position) else {
                        return nil
                    }
                    return (
                        position,
                        (1...steps)
                            .map { state.position.move(in: state.direction, step: $0) }
                            .map { (position: Position) -> Int in grid.points[position]!.val }
                            .sum
                    )
                }
                return positions
                    .flatMap { position, cost in
                        return [state.direction.rotate(.left), state.direction.rotate(.right)]
                            .map { (State(position: position, direction: $0), cost) }
                    }
            })!
        let path = zip(best, best.dropFirst())
            .flatMap { lhs, rhs in
                let distance = lhs.position.distance(to: rhs.position)
                return (1...distance).map { lhs.position.move(in: lhs.direction, step: $0) }
            }
        let cost = path.map { grid.points[$0]!.val }
        // 1381 is too high, 1059 is too high, 1017 too high
        return cost.sum
    },
    part2: { input in
        let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { Int(String($0))! }})
        let end = Position(x: grid.xRange.upperBound, y: grid.yRange.upperBound)
        let all = grid.data.map(\.val).sum
        let start = State(position: .init(x: 0, y: 0), direction: .right)
        let best: [State] = aStar(
            start: start,
            finished: { $0.position == end },
            estimatedCostToFinish: { $0.position.distance(to: end) },
            candidates: { state in
                let positions = (4...10).compactMap { steps -> (Position, Int)? in
                    let position = state.position.move(in: state.direction, step: steps)
                    guard grid.positions.contains(position) else {
                        return nil
                    }
                    return (
                        position,
                        (0..<steps)
                            .map { state.position.move(in: state.direction, step: $0) }
                            .map { (position: Position) -> Int in grid.points[position]!.val }
                            .sum
                    )
                }
                return positions
                    .flatMap { position, cost in
                        return [state.direction.rotate(.left), state.direction.rotate(.right)]
                            .map { (State(position: position, direction: $0), cost) }
                    }
            })!

        let path = zip(best, best.dropFirst())
            .flatMap { lhs, rhs in
                let distance = lhs.position.distance(to: rhs.position)
                return (1...distance).map { lhs.position.move(in: lhs.direction, step: $0) }
            }
        let cost = path.map { grid.points[$0]!.val }
        // 1294 is too high, 1209 is too high, 1207 is too high
        return cost.sum
    },
    testResult: (102, 71),
    testInput: #"""
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""#,
    part2TestInput: #"""
111111111111
999999999991
999999999991
999999999991
999999999991
"""#,
    input: #"""
222444333311413424552343154431445446552424344463624622324524534456326633244563653433366525542526324355665354353431435231331211151143142121442
311411341331544324152423112145232244226435343452524665363543446226525253253433625366655533554456522435326254434551143232253254144123214313332
332142322154314351451514421141223526365224325466522366465644325563563625326354653555623222224346434243224326335123224335132123142312243344432
341321343353435315411315145213462565443546263565434542634542233622362355462433563354546624423354426265366465355443242514511523545352224313334
423232151243241232443345514535235433443343455335462522554644522534235334533236353262442542352443535443454622446262623134243114314153232121314
142211232212123112255555132453562625346655466653646665333536323257566363656444355346332234654622435324664345434555322355113425253255243134141
442442432223545423114342264345563626466223223233243665633666355775576545337533646777736556324463234356455336624263442512331412455534515132144
433151313444541522135241265362632344353446553266342662766776337563537377336576754654567744522533656542322222562552565263421441445123515552132
232511144235215444333246423456263464253443526253656764775333737354767676455567773545657665336436362354526235363353322234254511313532335143143
344245131223431245415462556563325354623555264345755554736736357366544744365433434753454763553755322624632466666335462465621323214341452555551
422151111221414432532632522323522556446366644436577446373747337746476467363367574664534334467534563465544464653423435326456235253111222335344
435221244241245114534653343245652235533554236447546474477763554344563564767343457755434455576644635336456635452554666552465652524142215314312
212555413355522535642345623362625655265337565766535644363576676746774537444634463765334546635343345347345454565534466562544234431545345243313
122113444553115425555622624242326566556367653475335337447356767433347554743665575433545563655547745675665443653434625564443326121245553315421
324444224344115226354224435565244335556767555746563633644475346663666335663576663336573466464564536644345346244526622455636422655335113314455
335335213432332555353436264454332464656536537767664755534553443447563765745645474377374364436343336763765443565456456426253264221435132142532
255213543242354562346244365343232447557443365456447665773657647463453356535545476447677733666655766667647654432222246642342252663325551313443
121155322325523323334464566462253473573465733656564437735734677645636554333457774556675474673566437774443437656366622323526656663612525313241
552241214441663536252342443345457665337436737445577334457545467455467774857343533555375755545334544673547743456534562545253525423545315311524
542155214145452663466422243246634354536747534346455356457735366844484666867458775674655576676746666445657666663335433665433443234326512225343
334441411526656626244236226525753774563365344777747563453658644487487766666785885448846365565646574636574357377666645465525362223442531255521
345522245363654256343525324465633343557337434555544765547684474565455884757856558566776564754356676536377365566666554455544666563556552143313
513251155333654655232566655466653645556575757443475458557586867886874485474645885588786658747345535757446746546736676325624364453662335554414
145552522543233322443223435745633557333454364465364747458687788554784457555445588645644584584876567356576454474364645322554532555353553355511
354135356224632543243444255467677743437636653467764466668856768667656554658744475646758887768744744444437374637644463336545446255266525434251
134315343332656463656662667564777566756355473885848548664485454677556887488658556578886876886786576734777454664656475364424443365444524264522
332353253646343423436454667777633736766777577467867677768774778545485847588587686687785784867687458455335664433753643555265624565625665355121
341415235356662253645456367375455644736455788686557787878666664547566846854767878467644557866555655845533677377446347335465524356466534336233
112524366324542332426577344376645473736376566487564646854788758667677688744547888758657478676788454466636745675774365567473553235253542524213
134165542445643524243753765443436734535687847556866844575744766487755675455876668867446458685877656756473736333553754643665336353532424623334
315446445534454262273777664567756453677885558444685844646654586488864447677658867866584454555878675555586536453534766376337445265422563465364
444633433335524453566553563547546777454656665578648464474755884688566446685478457447584544865675786585545736763335367374466553364264556453655
244225433466534325636754643353775356554844555748747678467858846898588657958666996648555574845877657484485647553475635443376655233363453563536
554424422463566437773573657563673457887556675465486655466848557565668579858989655576477877474887484755445577764347654556655537324256562324245
153432532262622665573435366455354574755678744766846576866875756989966889958955888987867668854456588686674668685647657644767643362256342322533
356352225442442473637374453553745768668886874846888787896879976655859587556575995975559866778446887647776866478375536453375534726534636455426
424642462426465357457437765467358668844547646854448668889555668967959659778879779795777767648566546747758478676345564735537376342654322626635
565543222643353465474754437676474577787588844755674689589876969879676699677969865865767777877556667868656488875867364334755373347536364633344
462255234642537334447453463545785588787788658485686697769869989558998856869677956788968769796674574664788684484646464357473466546523666225434
332235565225576747536766736535855584464688745847556565775975779777698866868768966768697655658966688558575846545664767543554355775665665452543
366324623424347466557753437475585775566847746679786558656795977976765775776957867798787675866666565786876787677784734575577535673563244565463
442332356463646637364455434755664664577686776959768855769587866566898678567898757755977657595785687658766554585454657353757773635564532654535
524542546224664335533375543854587884764466545796776795667895977589679859586667659965797655886968986775688444754575477347633556574544366632334
645223522225363554634657754558775774757586869966688767566655757796775586659557668899799995585678756958864645656685565544463364745536624342253
633546635346436647465337477855684856878448996585769588876769665977657556557579675877866776897656986685658678568747884753645646434477622335644
453445352345634333344535766644746784657788596778797798657957877955678779877697776966985667589588956556586555468644486563363373546367723225233
262542243474376533534336774758774476745458989868967759987957875796889968679786889656765588985969598958957464464648676543677343657364533663442
666436543666435334346443846878556686658456885978985796685767987888997976966879969689875769688696979897874447646687854767555657457463453336546
636356265574736336367445856458788458767696675897865975998666887668897767787677668787686885995797667688776448785578586545537476766773473446655
554455263453335335677544648786444477657855986575899886655788688896667797899679788999765579798689577955878665754686576857774665567754442533236
565422645475353446675754645685457765876986786577966955898768696889876789886777777976867857775968965696698848877548648676357474634536465243443
632344237446533633533558558547555668469656756859679986677877997698978768976996797797896979857986698978959967554565886448434337354637773346526
522424426543473763755586874657665457775766987856896799788788699987689878667796666868979969899695799958859878485665855655754674434377665422346
346432563353435546365777547474775884975687968889569579797776879798866699686996797866887766959866868698698955874858866564656667743674555626445
343562455465746675564556548775577846956875865567799866799966897779969796678776867768779698679788768797555856767755864444587453564774564726636
442446553563573744754748744548868567985768596777697977799966967769989699769777889879966669797695778789659957748464487676473746754756573543634
254463657677744636674568545664764646885588766785796786967996967796687696887778786969998868896875687655989999464848877576846533536454437343524
535463267666653547575754676467644556889577796658697676986876779766776876697879897689898988899868696585785657554744888864488364765666646452622
543262657544676333756544884577844567595767796756776679886668897966879888879869979876968698997878676886779855954547746484488437767446764452363
363436577533634755455784788865855866595877898569899979669896898688999988789896966878678888986897576559556698988554656844544745557537355434232
524655363346743563336684488488787977897775689589799878688889897889988998797878788796896769767896998885679965568884765468546654636375557746454
544652735355433366746544484588577967578965999796987878778796886777777898889797988967676866879766759777575979886567484854787834456665535432536
446434745734533333684885484754466969787585987556969679898696977778978888898787787969696799976669668568556566675447855547554756566565677654665
263524334567435365554866766874745988566668968676676687689976788888988788798777987867979776886997976959867985658567676554577833477665563774355
535254674673344766474486886546575676678665577779967698876787889899788898779897879997667778696778675568767898858645768546687734655674376655332
664664564337345643677747544567568885795597757988996999769898788977789799788987999997799798878986789788866677577884766484468864377544366544522
353224476443347673586557565644659965878787556677779889897979997897897997788798988887967867689897769595589758997646787446574677635375664453365
653235345467445663565864488458748598678558797696786699889899777979989999889987778788787789998699668976596967965545474445774767366756344344265
352226653773456455666868668746588579669896665787678768889977878779977799897778878788779998688996765696698956957758685655447477754735667664666
545426353656434647578584556856659866688567876778866876778998899889997977879787799998788889979968865979877776985877555848788847755674664755542
323636377735466367764587886645575598658689658778999867976677887989878897998777797978897799778898666998558995657567558484844757475777755635344
332543673675347755457555675745888678876855986879777669796798898887787978788999799988766686888868995697977775697877565847845743746577577764536
366357775474753363586564465758759976789675967777876968777987989799797999978877879977878887788876875888878888955874748576546575654633457434435
463447644764667574775648865487489666899669865969766878868999977798779987998998898987976768889998766688955759759766585486787545637476637345223
356626333565636637587475774756787788796958897688886687787687789997798879977987879777898776779778687755597799779854447687587657447734634666533
445567753356567747678867447686468886788657559866868896688869898897879989998997878897798998869868988685688577866466466747544874777664445464244
235565454644675536674844784745677586987967969968679777687767999787779887778979978889896798897876999676858597557756664757756657554455356344526
244257656654774467547586877548446758598666856768687669879997987877977788889799988877677777677877985555576797686585684874446836556765546655232
345245476544555343645654584758645995878885686697796777696966778889989987787797997988787989787799865557775578867565778686757836346447756554663
553265444646466677677557456546785895889575788798797777887698788779787997889898879997796689899666997975559797676566875567674544445544776533632
633354763353666773685868484455684955587969768759877669676896698988878997787898777868999967769768889698955557977445684646665577735763457336322
446624364743346734768488885667754695566678668997698698789767887777788978999778887788879897979696589769797767587844454785656663356356677355446
234354554643333477764767786586668567669885756756666976698889898777898878979887996789786876977978668675666766688757688648768746333647455756452
632466377475436353336544454655765867769859987865968866779788997677797898777999869769798888768879765587859777857586675764678757335565653563646
233563674775377773574885777475644869887959865975699767869999669776877898887799999896776789687796575769875895968887654444748556433555343533353
234653463644676744554668655584457668689668859585687679976699997879796697987868677968877868786969887897867878565847675547756663373333646554352
664363363753353777563584788565857546975799875555557998896668996679969997796989979988688697896659959867759786588766786655653556567476765763545
354222455335363337535648545755467886956555696978887666767976668796777878997689868686668987688695896568998658455544764645574345575744567334533
334355674345357647575788564676878589586956667689566666689897778766797986766797767888869679797658566688766557467566847477865344353545345536233
354456323545747537446558687888668586986779765998779569669876679698797686676978797978888987696976695757665955678554848477473566436445675554453
322346323575335333446388685746788477656879758977769678869888866677967789879678886889897968988987779698976976556885654688474764764334764553654
253666357566444436537588786478877755477797957686999775998696977668998966886779767676968776667969558898589675767587777874874473737435755224462
422466226374757537577478856787567747887789575867697688698999787998777667897779886879869876797865897998986467886774764448556467636653763323534
355252632767465665745337878466448687477975986675958978878766869786898797778878798967876586955566976697787458688847677856545455573377576542226
234632233775535664634557876886655475847879659789969567758588799796669787769667699666666966776597657879965887655687655887734574355435456534264
324555533566777337446377578658688567745686767859979668966656689686688788877996879676786785976957889999558457688586486575657767456676552653645
525634663537754746577533365654467668767767679986997657979695599889798667698798668586977698558766599956948755485775555444577775435556722462462
565556352377765645676363746778847876474877999568868599775777565555876689968979595868679959755875757676767657444744577456443777665737623544545
633332556666754774336774666645545575676448678966866959858755588578559979766775697875975897865876969595685485678756847533646335335557436366362
646235544645463574434444664754755666566545869566875989757657855657859886699796589695575957956796889655457474445686578735636376365676555626225
552326346245337465367565343654677857747556789858687896876965967887987796898886768988897566865957887477468445887657773453467334653665456363653
562453262355336546655344756677657647486858865698755777867759995968758785569996787578659999568657866876677577654744637545373376645754253553343
262526444545666747565346745367866654658764885575998786989689559775998897697678695699759567567788748784565844687756433735757535467765433635255
422462254523657653746363435568786684775776888575578887698758569856889858755876879978976888756896468878487848845874335755465337343663222255262
322643626436534447477575343436545664548544484584688597669659575579576569958685888765957786785655474454774545475553336375545467357625566534555
455422636626323776465653464477464445564866684744858696599876568797659967957586767995669969684774877845447888547533564534565335634365664456354
653633566365525434663446646434364668774547465554565889785655765897679956568885688555998898574587646868475785457735454374347737764523263435553
255322364636633474475665777733567846668855844455665545599995778955775869796778965967888596466845846858486875678454673765677545745465542463353
454626522665223265343365753464366878876847556466587547888679957665588656878568799666587486778468558568484656763756763574365663625443624325362
233353342343462264534635575535567355557765877747856458567647978756857875855588779968475868678574855844475775534565635375373447565352332525535
112522364223665642435543753565573434657574786756584488486887868857877586885797964855487745465854767457446774476354733656775455663245245334445
145226232424555426637645533445445653346545477545687588474845655587878644847568768577476475675886554675546863467446364733365363264353663336465
221342536554224422575755333664356463546678885477554554747584787577758776886456867446547774788648457867577654533477334574776655423355323252423
344132565645524544247566333455746543656756754754875888646585475677776874578545856857588467466784755667583337555665656664454644624262446533333
313145563243246553456677343777437475534477548747745745554765644644878857467675785685455676645666555667655737733346343533534532335243532425652
232216636566422246352255737437534657545773844744785855554775674666465687857485746677444644766656568887435334574565456373546332656655355236324
123112346255662224642626733557567673754357447657875854577645865678476758747585855755767764476658575564376477773777653766264364223226543435212
455212245233622434522463774775353544346374343447886668465465765446545858575648575885647768854564653535734477534773375563456323442334532533345
223212466662332635445433573776776736447344734446785747764674776455468484666577747475477467554875737544575536773755475462225432644555335254343
332315524463263434646222364537633367635567776556745866654654586488488468455574858556848555455663434356477634343354546554324635532366524135541
312252153655655265436653542664536435365537653653467864784447884775758565856587558668766646476566373363455637665463362362554534434542645454225
345455145333243223254223522366574735663657443766447467846845584867778875566745487675758666636735645367744735353643423466264423653525534512224
532422112544634554266562432665444774553357575366466677444754455764457564778766745675756557377737573755373733473356623355226625252642443343435
155512555456435432664652663323645374535575435534663734635745768468575888477647658637666637756755535576475776353473644556322236663545123424222
414242552515525564335242432543567457376455643733774546546356457775436588664535444543436667533476776356433356577363333255445343634664234422412
144532411433254544364464566423245566563455657335767454633376557336554654655535674733553557765563575354533775662246632262666662442622525212244
525335511532515665646622623526443437336574457556564564353765655565474564464343765767334736665534366433754574663545562433554526443125431425322
155551524234443362652335546336555324743676445377773536533655743356774654355655453535365467577774465565765454355446335262644564431333523333353
235542415434232535666435266455264335464754733477356336375434673637755663543747366376557777347744677363564436655453533635354562311222252513542
311322252332435152322464236262566423533675477364447437546376754663757636454467735374756657677355733357452532566662644466324345151431535113341
321552545551214234546224543636555256524353676656674646754455775573764765364553656537647675344363454766665332625456432455252442321354312111453
112544424343255411232264345343363332242564574343647473367347754534757433664573475565356743633756545354542323465326432364233632323251323145255
152432112343432155344636255552634455655543262455646574353663745753574344643457565475775654475743475345335323536662522542452511332514222223425
341454535223142221351433634252535546524544542635555435477644776743654645735554756554357335447446266535542536342463265562533411543131554515113
222451214114521422222356424556544636232565566354433446436367435466565753745465376346454565443322346555422265433664443555153221315553232132343
314444333511231422552155663223342634423553635646264225356764574655365766745474545444563343244353335462663665356422264223511321352332315143142
222324114553123353335522232244624452643432336254453642445673773345474676557547757775622254343524656654646263232645425432231113144511213324422
214412212241154531125221132263363425446644553435524662525636464677756564347634552235533326442532345423664265625334255451212354335515411313343
322242354551352354351123433266633445465635554435442544433356555324335225465656224253234346643642354346246355342332411133352551444542254122213
333421444155343533415323335443233226333562522663652346242645354653345234463325524624255355254563632454452564442244311133232432142425115144121
343231111432333411445111531235226324634533235545424464234445664442335446522356254434453222366266466332343644264341442114431131333124334431141
"""#
)
