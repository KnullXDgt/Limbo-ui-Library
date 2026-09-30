local Limbo = {}
local LIB_VERSION = "2.0.7"
Limbo.Version = LIB_VERSION

Limbo._resetCallbacks = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer.PlayerGui
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local ConfigFolder = "LimboFishIt"

local function CircleClick(Button, X, Y)
    spawn(
        function()
            Button.ClipsDescendants = true
            local Circle = Instance.new("ImageLabel")
            Circle.Image = "rbxassetid://266543268"
            Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
            Circle.ImageTransparency = 0.9
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.BackgroundTransparency = 1
            Circle.ZIndex = 10
            Circle.Name = "Circle"
            Circle.Parent = Button

            local NewX = X - Circle.AbsolutePosition.X
            local NewY = Y - Circle.AbsolutePosition.Y
            Circle.Position = UDim2.new(0, NewX, 0, NewY)
            local Size = 0
            if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.X * 1.5
            elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.Y * 1.5
            elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
                Size = Button.AbsoluteSize.X * 1.5
            end

            local Time = 0.5
            Circle:TweenSizeAndPosition(
                UDim2.new(0, Size, 0, Size),
                UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
                "Out",
                "Quad",
                Time,
                false,
                nil
            )
            for i = 1, 10 do
                Circle.ImageTransparency = Circle.ImageTransparency + 0.01
                wait(Time / 10)
            end
            Circle:Destroy()
        end
    )
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos =
            UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position

                input.Changed:Connect(
                    function()
                        if input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                        end
                    end
                )
            end
        end
    )

    topbarobject.InputChanged:Connect(
        function(input)
            if
                input.UserInputType == Enum.UserInputType.MouseMovement or
                    input.UserInputType == Enum.UserInputType.Touch
             then
                DragInput = input
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end
    )
end

local function MakeDraggableMobileButton(button, object, screenGui)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    local ClickStartPos = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local newX = StartPosition.X + Delta.X
        local newY = StartPosition.Y + Delta.Y

        local screenSize = screenGui.AbsoluteSize
        local buttonSize = object.AbsoluteSize

        local padding = 10
        newX = math.clamp(newX, padding, screenSize.X - buttonSize.X - padding)
        newY = math.clamp(newY, padding, screenSize.Y - buttonSize.Y - padding)

        object.Position = UDim2.new(0, newX, 0, newY)
    end

    pcall(function() button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            ClickStartPos = input.Position
            DragStart = input.Position
            pcall(function()
                StartPosition = Vector2.new(object.AbsolutePosition.X, object.AbsolutePosition.Y)
            end)
            if not StartPosition then
                StartPosition = Vector2.new(object.Position.X.Offset, object.Position.Y.Offset)
            end
        end
    end) end)

    pcall(function() UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end) end)

    pcall(function() button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if not Dragging and ClickStartPos then
                local dragDistance = (input.Position - ClickStartPos).Magnitude
                if dragDistance > 5 then Dragging = true end
            end
            DragInput = input
        end
    end) end)

    pcall(function() UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end) end)

    return function()
        return Dragging
    end
end

local function MakeResizable(resizeHandle, targetObject, minSize, maxSize, onResize)
    minSize = minSize or Vector2.new(300, 200)
    maxSize = maxSize or Vector2.new(1000, 800)

    local isResizing = false
    local resizeStartPos = nil
    local startSize = nil
    local startMousePos = nil

    resizeHandle.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = true
                resizeStartPos = targetObject.Position
                startSize = Vector2.new(targetObject.Size.X.Offset, targetObject.Size.Y.Offset)
                startMousePos = input.Position

                input.Changed:Connect(function()
                    if not isResizing then return end
                    if input.UserInputState == Enum.UserInputState.End then
                        isResizing = false
                        return
                    end
                    local delta = input.Position - startMousePos
                    local newWidth  = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
                    local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
                    targetObject.Size = UDim2.new(0, newWidth, 0, newHeight)
                    if onResize then onResize(Vector2.new(newWidth, newHeight)) end
                end)
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = false
            end
        end
    )
end


local LucideIcons = {['a-arrow-down']='rbxassetid://92867583610071',['a-arrow-up']='rbxassetid://132318504999733',['a-large-small']='rbxassetid://111491496660216',accessibility='rbxassetid://114029945302017',activity='rbxassetid://94212016861936',['air-vent']='rbxassetid://81517226012329',airplay='rbxassetid://115020759309179',['alarm-clock-check']='rbxassetid://76437352099157',['alarm-clock-minus']='rbxassetid://77364179863205',['alarm-clock-off']='rbxassetid://97904885874823',['alarm-clock-plus']='rbxassetid://80468822979214',['alarm-clock']='rbxassetid://126259032907535',['alarm-smoke']='rbxassetid://96965448419685',album='rbxassetid://127358331163602',['align-center-horizontal']='rbxassetid://81570549209434',['align-center-vertical']='rbxassetid://118470463752466',['align-end-horizontal']='rbxassetid://139502909745427',['align-end-vertical']='rbxassetid://96528869059554',['align-horizontal-distribute-center']='rbxassetid://97220086126656',['align-horizontal-distribute-end']='rbxassetid://106128590702022',['align-horizontal-distribute-start']='rbxassetid://76074660002997',['align-horizontal-justify-center']='rbxassetid://75732302772427',['align-horizontal-justify-end']='rbxassetid://129167626402283',['align-horizontal-justify-start']='rbxassetid://130161830325281',['align-horizontal-space-around']='rbxassetid://91646106782950',['align-horizontal-space-between']='rbxassetid://103886093046990',['align-start-horizontal']='rbxassetid://125674804697729',['align-start-vertical']='rbxassetid://105020230154823',['align-vertical-distribute-center']='rbxassetid://93791183635525',['align-vertical-distribute-end']='rbxassetid://139354223511433',['align-vertical-distribute-start']='rbxassetid://74961997822126',['align-vertical-justify-center']='rbxassetid://134754696166569',['align-vertical-justify-end']='rbxassetid://92569381441969',['align-vertical-justify-start']='rbxassetid://99692844572718',['align-vertical-space-around']='rbxassetid://96206012459190',['align-vertical-space-between']='rbxassetid://124998077349706',ambulance='rbxassetid://78599995190651',ampersand='rbxassetid://75272915739209',ampersands='rbxassetid://126947193455996',amphora='rbxassetid://137370389604364',anchor='rbxassetid://92181172123618',angry='rbxassetid://74237056000103',annoyed='rbxassetid://80064369052011',antenna='rbxassetid://99628923540956',anvil='rbxassetid://100203029845919',aperture='rbxassetid://83396154449972',['app-window-mac']='rbxassetid://79587216113811',['app-window']='rbxassetid://93142176757189',apple='rbxassetid://104349242902442',['archive-restore']='rbxassetid://78956681942188',['archive-x']='rbxassetid://75830115088395',archive='rbxassetid://122180020814574',armchair='rbxassetid://105384358373973',['arrow-big-down-dash']='rbxassetid://137987229582002',['arrow-big-down']='rbxassetid://81081164158885',['arrow-big-left-dash']='rbxassetid://97827621354677',['arrow-big-left']='rbxassetid://85973092492641',['arrow-big-right-dash']='rbxassetid://117825834972403',['arrow-big-right']='rbxassetid://82960676755590',['arrow-big-up-dash']='rbxassetid://99260194327483',['arrow-big-up']='rbxassetid://93136954756149',['arrow-down-0-1']='rbxassetid://120961896217875',['arrow-down-1-0']='rbxassetid://93474255891850',['arrow-down-a-z']='rbxassetid://99554596207900',['arrow-down-from-line']='rbxassetid://132045845807798',['arrow-down-left']='rbxassetid://102899325237364',['arrow-down-narrow-wide']='rbxassetid://129105261655061',['arrow-down-right']='rbxassetid://123109928624974',['arrow-down-to-dot']='rbxassetid://101675355931221',['arrow-down-to-line']='rbxassetid://87050478931254',['arrow-down-up']='rbxassetid://85780258549577',['arrow-down-wide-narrow']='rbxassetid://88461733425991',['arrow-down-z-a']='rbxassetid://76115279362232',['arrow-down']='rbxassetid://98764963621439',['arrow-left-from-line']='rbxassetid://87857914437603',['arrow-left-right']='rbxassetid://131324733048447',['arrow-left-to-line']='rbxassetid://118645136026970',['arrow-left']='rbxassetid://102531941843733',['arrow-right-from-line']='rbxassetid://74073639809355',['arrow-right-left']='rbxassetid://77015754304300',['arrow-right-to-line']='rbxassetid://78632510329852',['arrow-right']='rbxassetid://113692007244654',['arrow-up-0-1']='rbxassetid://105257823943016',['arrow-up-1-0']='rbxassetid://134175521693798',['arrow-up-a-z']='rbxassetid://77763416595160',['arrow-up-down']='rbxassetid://81019887641527',['arrow-up-from-dot']='rbxassetid://124408496673275',['arrow-up-from-line']='rbxassetid://95777664626453',['arrow-up-left']='rbxassetid://123490598231261',['arrow-up-narrow-wide']='rbxassetid://73006024672636',['arrow-up-right']='rbxassetid://129280608535523',['arrow-up-to-line']='rbxassetid://108818207813537',['arrow-up-wide-narrow']='rbxassetid://87437426951568',['arrow-up-z-a']='rbxassetid://107546173611884',['arrow-up']='rbxassetid://89282378235317',['arrows-up-from-line']='rbxassetid://133710016938621',asterisk='rbxassetid://88552752106723',['at-sign']='rbxassetid://79059152889146',atom='rbxassetid://73167696981648',['audio-lines']='rbxassetid://70930641819242',['audio-waveform']='rbxassetid://86462036665209',award='rbxassetid://132740088158419',axe='rbxassetid://132405197863294',['axis-3d']='rbxassetid://122438676546804',baby='rbxassetid://93472926933440',backpack='rbxassetid://140420225386018',['badge-alert']='rbxassetid://101829200081951',['badge-cent']='rbxassetid://133345018873154',['badge-check']='rbxassetid://76078495178149',['badge-dollar-sign']='rbxassetid://127139803581141',['badge-euro']='rbxassetid://120016477674659',['badge-indian-rupee']='rbxassetid://75659682309981',['badge-info']='rbxassetid://131995373201472',['badge-japanese-yen']='rbxassetid://99081574588615',['badge-minus']='rbxassetid://140321561183881',['badge-percent']='rbxassetid://121359224294885',['badge-plus']='rbxassetid://100325578561866',['badge-pound-sterling']='rbxassetid://119688217279444',['badge-question-mark']='rbxassetid://121464963737502',['badge-russian-ruble']='rbxassetid://108839463659864',['badge-swiss-franc']='rbxassetid://91447608372740',['badge-turkish-lira']='rbxassetid://137839965873529',['badge-x']='rbxassetid://122931434733842',badge='rbxassetid://116620312917084',['baggage-claim']='rbxassetid://86922213051957',ban='rbxassetid://90767043015246',banana='rbxassetid://140713420056179',bandage='rbxassetid://129660129590770',['banknote-arrow-down']='rbxassetid://139366449345199',['banknote-arrow-up']='rbxassetid://133758343082529',['banknote-x']='rbxassetid://95348701438065',banknote='rbxassetid://104840231536668',barcode='rbxassetid://118473018143689',barrel='rbxassetid://130647115622774',baseline='rbxassetid://124677132511270',bath='rbxassetid://76031400297942',['battery-charging']='rbxassetid://80139357470047',['battery-full']='rbxassetid://70906718268972',['battery-low']='rbxassetid://139659256984314',['battery-medium']='rbxassetid://105934079398915',['battery-plus']='rbxassetid://91931341486966',['battery-warning']='rbxassetid://115230083817257',battery='rbxassetid://70765800346189',beaker='rbxassetid://80902539995520',['bean-off']='rbxassetid://98164436608714',bean='rbxassetid://89491967076869',['bed-double']='rbxassetid://73820193212911',['bed-single']='rbxassetid://113423940880634',bed='rbxassetid://97726529032925',beef='rbxassetid://105850162318915',['beer-off']='rbxassetid://120333134736361',beer='rbxassetid://116404978807744',['bell-dot']='rbxassetid://93161277118810',['bell-electric']='rbxassetid://100277767266983',['bell-minus']='rbxassetid://126334890449727',['bell-off']='rbxassetid://78560046118930',['bell-plus']='rbxassetid://77014333795836',['bell-ring']='rbxassetid://94612128913941',bell='rbxassetid://97392696311902',['between-horizontal-end']='rbxassetid://81602774794322',['between-horizontal-start']='rbxassetid://76112384929846',['between-vertical-end']='rbxassetid://72817612571631',['between-vertical-start']='rbxassetid://85278312190301',['biceps-flexed']='rbxassetid://82004462003936',bike='rbxassetid://102930322246035',binary='rbxassetid://91751953950088',binoculars='rbxassetid://101460003267896',biohazard='rbxassetid://95956532900432',bird='rbxassetid://132284145117371',birdhouse='rbxassetid://83999157401433',bitcoin='rbxassetid://95459240442938',blend='rbxassetid://111679612185257',blinds='rbxassetid://71164165283925',blocks='rbxassetid://72212693357737',['bluetooth-connected']='rbxassetid://96315134002985',['bluetooth-off']='rbxassetid://80600044218117',['bluetooth-searching']='rbxassetid://100673019606426',bluetooth='rbxassetid://90506573139443',bold='rbxassetid://116141470019166',bolt='rbxassetid://102881251417484',bomb='rbxassetid://139223800924636',bone='rbxassetid://111242153474115',['book-a']='rbxassetid://104067275658465',['book-alert']='rbxassetid://124159928044853',['book-audio']='rbxassetid://109208148317037',['book-check']='rbxassetid://115999656081696',['book-copy']='rbxassetid://108543407492005',['book-dashed']='rbxassetid://127430784795958',['book-down']='rbxassetid://101011730128222',['book-headphones']='rbxassetid://108670200799574',['book-heart']='rbxassetid://112788845135284',['book-image']='rbxassetid://80808285757226',['book-key']='rbxassetid://116024426170705',['book-lock']='rbxassetid://118765061220571',['book-marked']='rbxassetid://73211024251780',['book-minus']='rbxassetid://112724962046282',['book-open-check']='rbxassetid://130848362492667',['book-open-text']='rbxassetid://100629528672195',['book-open']='rbxassetid://129845326810392',['book-plus']='rbxassetid://140267785051233',['book-text']='rbxassetid://94011772484232',['book-type']='rbxassetid://97817304725443',['book-up-2']='rbxassetid://130161620853665',['book-up']='rbxassetid://98640174079190',['book-user']='rbxassetid://128489189240523',['book-x']='rbxassetid://118754548186537',book='rbxassetid://125383279695672',['bookmark-check']='rbxassetid://93940443347986',['bookmark-minus']='rbxassetid://96807096039910',['bookmark-plus']='rbxassetid://121469724491615',['bookmark-x']='rbxassetid://112272342584706',bookmark='rbxassetid://121093149326239',['boom-box']='rbxassetid://99901322535868',['bot-message-square']='rbxassetid://96145330292478',['bot-off']='rbxassetid://140417690560013',bot='rbxassetid://80451686744860',['bottle-wine']='rbxassetid://131675403196921',['bow-arrow']='rbxassetid://124089655150375',box='rbxassetid://101768155599700',boxes='rbxassetid://136372617578355',braces='rbxassetid://117761094704041',brackets='rbxassetid://74368995728099',['brain-circuit']='rbxassetid://70547962410202',['brain-cog']='rbxassetid://132039205501538',brain='rbxassetid://92424107303177',['brick-wall-fire']='rbxassetid://92980588705520',['brick-wall-shield']='rbxassetid://75954432775071',['brick-wall']='rbxassetid://112878522258821',['briefcase-business']='rbxassetid://129135125207283',['briefcase-conveyor-belt']='rbxassetid://108665725653714',['briefcase-medical']='rbxassetid://119917756334087',briefcase='rbxassetid://96754188164225',['bring-to-front']='rbxassetid://132975903553748',['brush-cleaning']='rbxassetid://71728977448805',brush='rbxassetid://127035535799640',bubbles='rbxassetid://106183424168227',['bug-off']='rbxassetid://88020025049245',['bug-play']='rbxassetid://80107955888092',bug='rbxassetid://83626408925438',['building-2']='rbxassetid://77873775611951',building='rbxassetid://110616258983082',['bus-front']='rbxassetid://89863432456045',bus='rbxassetid://133798469717463',['cable-car']='rbxassetid://128643682205596',cable='rbxassetid://128449944504901',['cake-slice']='rbxassetid://136769828413242',cake='rbxassetid://103131590503275',calculator='rbxassetid://74915716529646',['calendar-1']='rbxassetid://98458364171044',['calendar-arrow-down']='rbxassetid://108415736543437',['calendar-arrow-up']='rbxassetid://70574654109118',['calendar-check-2']='rbxassetid://120231170248276',['calendar-check']='rbxassetid://71551019465748',['calendar-clock']='rbxassetid://119132152594595',['calendar-cog']='rbxassetid://122402172360287',['calendar-days']='rbxassetid://99072017568595',['calendar-fold']='rbxassetid://117368871270394',['calendar-heart']='rbxassetid://88839008103676',['calendar-minus-2']='rbxassetid://98846170279891',['calendar-minus']='rbxassetid://137354318924383',['calendar-off']='rbxassetid://109726151749217',['calendar-plus-2']='rbxassetid://112264562093883',['calendar-plus']='rbxassetid://125266115249843',['calendar-range']='rbxassetid://103641849247576',['calendar-search']='rbxassetid://92010083223634',['calendar-sync']='rbxassetid://78082218499697',['calendar-x-2']='rbxassetid://107518051061147',['calendar-x']='rbxassetid://106703374806500',calendar='rbxassetid://114792700814035',['camera-off']='rbxassetid://81057636835256',camera='rbxassetid://79950339943067',['candy-cane']='rbxassetid://71689468772492',['candy-off']='rbxassetid://110232752314832',candy='rbxassetid://107812129154678',cannabis='rbxassetid://98792006538601',['captions-off']='rbxassetid://105223545364193',captions='rbxassetid://104960225031445',['car-front']='rbxassetid://87380942739063',['car-taxi-front']='rbxassetid://122455403384057',car='rbxassetid://121065933462582',caravan='rbxassetid://120070979471783',['card-sim']='rbxassetid://134490550095771',carrot='rbxassetid://119118221444304',['case-lower']='rbxassetid://129303130603241',['case-sensitive']='rbxassetid://125410273293056',['case-upper']='rbxassetid://111633433531325',['cassette-tape']='rbxassetid://137065788934157',cast='rbxassetid://98202245922071',castle='rbxassetid://119275077187784',cat='rbxassetid://124252153404931',cctv='rbxassetid://99979894766624',['chart-area']='rbxassetid://123446436762366',['chart-bar-big']='rbxassetid://72336824986044',['chart-bar-decreasing']='rbxassetid://107217459044963',['chart-bar-increasing']='rbxassetid://88268905998571',['chart-bar-stacked']='rbxassetid://98478751113024',['chart-bar']='rbxassetid://105389816384108',['chart-candlestick']='rbxassetid://125676898615697',['chart-column-big']='rbxassetid://98598733210787',['chart-column-decreasing']='rbxassetid://73586137373563',['chart-column-increasing']='rbxassetid://120421615068601',['chart-column-stacked']='rbxassetid://86031449675105',['chart-column']='rbxassetid://97915995538580',['chart-gantt']='rbxassetid://88811660555940',['chart-line']='rbxassetid://101833156055618',['chart-network']='rbxassetid://104027882693561',['chart-no-axes-column-decreasing']='rbxassetid://123371717192542',['chart-no-axes-column-increasing']='rbxassetid://140383830943049',['chart-no-axes-column']='rbxassetid://94078751170351',['chart-no-axes-combined']='rbxassetid://121424233161912',['chart-no-axes-gantt']='rbxassetid://131936541106368',['chart-pie']='rbxassetid://113412261630136',['chart-scatter']='rbxassetid://108217585014571',['chart-spline']='rbxassetid://90307460742494',['check-check']='rbxassetid://95183312173858',['check-line']='rbxassetid://115122343485290',check='rbxassetid://93898873302694',['chef-hat']='rbxassetid://121744015002573',cherry='rbxassetid://139519182403183',['chess-bishop']='rbxassetid://121701705580238',['chess-king']='rbxassetid://90885687223462',['chess-knight']='rbxassetid://96467707042169',['chess-pawn']='rbxassetid://111318574652751',['chess-queen']='rbxassetid://98304702099749',['chess-rook']='rbxassetid://76223925830262',['chevron-down']='rbxassetid://134243273101015',['chevron-first']='rbxassetid://105243363790238',['chevron-last']='rbxassetid://89268452603731',['chevron-left']='rbxassetid://73780377692148',['chevron-right']='rbxassetid://92473583511724',['chevron-up']='rbxassetid://122444883127455',['chevrons-down-up']='rbxassetid://139404716013205',['chevrons-down']='rbxassetid://100524612205956',['chevrons-left-right-ellipsis']='rbxassetid://125035817741526',['chevrons-left-right']='rbxassetid://87910685945204',['chevrons-left']='rbxassetid://82617201744347',['chevrons-right-left']='rbxassetid://87149546686569',['chevrons-right']='rbxassetid://139121276490483',['chevrons-up-down']='rbxassetid://131833120209646',['chevrons-up']='rbxassetid://100467452364672',chromium='rbxassetid://128165143739006',church='rbxassetid://113714744350666',['cigarette-off']='rbxassetid://77797883078452',['circle-alert']='rbxassetid://83898160590116',['circle-arrow-down']='rbxassetid://95901860261344',['circle-arrow-left']='rbxassetid://102148876968988',['circle-arrow-out-down-left']='rbxassetid://140598097856694',['circle-arrow-out-down-right']='rbxassetid://119952801379305',['circle-arrow-out-up-left']='rbxassetid://132858212688303',['circle-arrow-out-up-right']='rbxassetid://81783743753173',['circle-arrow-right']='rbxassetid://70786767999559',['circle-arrow-up']='rbxassetid://84395128546494',['circle-check-big']='rbxassetid://93202927221730',['circle-check']='rbxassetid://85262178816537',['circle-chevron-down']='rbxassetid://137069490345718',['circle-chevron-left']='rbxassetid://130250009740827',['circle-chevron-right']='rbxassetid://125943696958495',['circle-chevron-up']='rbxassetid://111223574026321',['circle-dashed']='rbxassetid://126799443883746',['circle-divide']='rbxassetid://106398997754208',['circle-dollar-sign']='rbxassetid://91106238890387',['circle-dot-dashed']='rbxassetid://111451232827180',['circle-dot']='rbxassetid://82947033619201',['circle-ellipsis']='rbxassetid://91687150884779',['circle-equal']='rbxassetid://95133963751438',['circle-fading-arrow-up']='rbxassetid://104648212910336',['circle-fading-plus']='rbxassetid://91847890443490',['circle-gauge']='rbxassetid://108157549473765',['circle-minus']='rbxassetid://133556159576809',['circle-off']='rbxassetid://97923456918886',['circle-parking-off']='rbxassetid://128369410981252',['circle-parking']='rbxassetid://124034962915196',['circle-pause']='rbxassetid://139337739700879',['circle-percent']='rbxassetid://133311912860256',['circle-play']='rbxassetid://120408917249739',['circle-plus']='rbxassetid://113157136350384',['circle-pound-sterling']='rbxassetid://105476153083828',['circle-power']='rbxassetid://140676030155098',['circle-question-mark']='rbxassetid://97516698664325',['circle-slash-2']='rbxassetid://136766902186549',['circle-slash']='rbxassetid://125206439913049',['circle-small']='rbxassetid://73685402843600',['circle-star']='rbxassetid://120318414957104',['circle-stop']='rbxassetid://87400503942659',['circle-user-round']='rbxassetid://95489465399880',['circle-user']='rbxassetid://136220511671311',['circle-x']='rbxassetid://76821953846248',circle='rbxassetid://130359823580534',['circuit-board']='rbxassetid://107695264369312',citrus='rbxassetid://139018222976433',clapperboard='rbxassetid://132660667070200',['clipboard-check']='rbxassetid://92649798577170',['clipboard-clock']='rbxassetid://123957515687745',['clipboard-copy']='rbxassetid://125851897718493',['clipboard-list']='rbxassetid://96460215958908',['clipboard-minus']='rbxassetid://107968008485671',['clipboard-paste']='rbxassetid://74382068849983',['clipboard-pen-line']='rbxassetid://77711589791615',['clipboard-pen']='rbxassetid://75290966822953',['clipboard-plus']='rbxassetid://134285318675662',['clipboard-type']='rbxassetid://89949374318028',['clipboard-x']='rbxassetid://102222456890103',clipboard='rbxassetid://89601995828423',['clock-1']='rbxassetid://129363225422045',['clock-10']='rbxassetid://104332695855541',['clock-11']='rbxassetid://119023205186105',['clock-12']='rbxassetid://117789618723068',['clock-2']='rbxassetid://134710777209413',['clock-3']='rbxassetid://136385631189327',['clock-4']='rbxassetid://121808839832144',['clock-5']='rbxassetid://85082019959457',['clock-6']='rbxassetid://71009733505593',['clock-7']='rbxassetid://103111188546225',['clock-8']='rbxassetid://110059272125337',['clock-9']='rbxassetid://77610027126437',['clock-alert']='rbxassetid://97157344465162',['clock-arrow-down']='rbxassetid://92349314416042',['clock-arrow-up']='rbxassetid://111484286332629',['clock-check']='rbxassetid://85231630218857',['clock-fading']='rbxassetid://93205297285245',['clock-plus']='rbxassetid://93367709263150',clock='rbxassetid://121808839832144',['closed-caption']='rbxassetid://99832644030788',['cloud-alert']='rbxassetid://91967273658626',['cloud-check']='rbxassetid://97318598202432',['cloud-cog']='rbxassetid://96497764065749',['cloud-download']='rbxassetid://121435581993566',['cloud-drizzle']='rbxassetid://139525315752605',['cloud-fog']='rbxassetid://76650233148776',['cloud-hail']='rbxassetid://72320462748242',['cloud-lightning']='rbxassetid://133517088924849',['cloud-moon-rain']='rbxassetid://127667837827018',['cloud-moon']='rbxassetid://71938114737914',['cloud-off']='rbxassetid://131907154501444',['cloud-rain-wind']='rbxassetid://107414583736721',['cloud-rain']='rbxassetid://105547081967408',['cloud-snow']='rbxassetid://72307126270226',['cloud-sun-rain']='rbxassetid://99041604425705',['cloud-sun']='rbxassetid://86114208148727',['cloud-upload']='rbxassetid://93307473217005',cloud='rbxassetid://121226497050352',cloudy='rbxassetid://105360479023346',clover='rbxassetid://74925550436750',club='rbxassetid://108490365816628',['code-xml']='rbxassetid://130150477351734',code='rbxassetid://107380207681249',codepen='rbxassetid://135643965971885',codesandbox='rbxassetid://106911852964823',coffee='rbxassetid://106864403231093',cog='rbxassetid://116544501716299',coins='rbxassetid://116510979641930',['columns-2']='rbxassetid://113004100221850',['columns-3-cog']='rbxassetid://121589691981064',['columns-3']='rbxassetid://115223357399375',['columns-4']='rbxassetid://130807991968419',combine='rbxassetid://79908476334048',command='rbxassetid://93648221906330',compass='rbxassetid://115123411028382',component='rbxassetid://110027788875080',computer='rbxassetid://77480056459407',['concierge-bell']='rbxassetid://140384259310436',cone='rbxassetid://97759550688437',construction='rbxassetid://106539489968173',['contact-round']='rbxassetid://71907624112229',contact='rbxassetid://75868297719012',container='rbxassetid://91507237573499',contrast='rbxassetid://112796643981497',cookie='rbxassetid://73159504540002',['cooking-pot']='rbxassetid://94959783129799',['copy-check']='rbxassetid://91177247988892',['copy-minus']='rbxassetid://109524509933035',['copy-plus']='rbxassetid://113618379616952',['copy-slash']='rbxassetid://93805787810390',['copy-x']='rbxassetid://106557557978061',copy='rbxassetid://78979572434545',copyleft='rbxassetid://78559055698593',copyright='rbxassetid://129433635747111',['corner-down-left']='rbxassetid://90473561177832',['corner-down-right']='rbxassetid://86512767702085',['corner-left-down']='rbxassetid://139876989150630',['corner-left-up']='rbxassetid://126228268096099',['corner-right-down']='rbxassetid://89237035551302',['corner-right-up']='rbxassetid://112851237026705',['corner-up-left']='rbxassetid://84669279763024',['corner-up-right']='rbxassetid://115099889693145',cpu='rbxassetid://77549309870247',['creative-commons']='rbxassetid://90408210735312',['credit-card']='rbxassetid://99163352872346',croissant='rbxassetid://130710485559420',crop='rbxassetid://116344601101413',cross='rbxassetid://101833377863588',crosshair='rbxassetid://134242818164054',crown='rbxassetid://127843403295538',cuboid='rbxassetid://75618807946111',['cup-soda']='rbxassetid://121098640829562',currency='rbxassetid://90551250119972',cylinder='rbxassetid://90569677179169',dam='rbxassetid://76874486231393',['database-backup']='rbxassetid://103403210984699',['database-zap']='rbxassetid://131199921258418',database='rbxassetid://126791525623846',['decimals-arrow-left']='rbxassetid://120198500638749',['decimals-arrow-right']='rbxassetid://118263047146797',delete='rbxassetid://126279426372342',dessert='rbxassetid://71508133278830',diameter='rbxassetid://97429051503783',['diamond-minus']='rbxassetid://128989071438290',['diamond-percent']='rbxassetid://107717860105959',['diamond-plus']='rbxassetid://134701163723675',diamond='rbxassetid://105846996304890',['dice-1']='rbxassetid://112650149591038',['dice-2']='rbxassetid://112278274566793',['dice-3']='rbxassetid://118526270626312',['dice-4']='rbxassetid://113365650364004',['dice-5']='rbxassetid://72768312430593',['dice-6']='rbxassetid://85376239182543',dices='rbxassetid://81268120302865',diff='rbxassetid://135052708609715',['disc-2']='rbxassetid://91419420404185',['disc-3']='rbxassetid://135470554736048',['disc-album']='rbxassetid://74693460404344',disc='rbxassetid://101908120120777',divide='rbxassetid://136678191878278',['dna-off']='rbxassetid://89612426361540',dna='rbxassetid://74007982981741',dock='rbxassetid://121997427160252',dog='rbxassetid://71920105558570',['dollar-sign']='rbxassetid://127320961224019',donut='rbxassetid://72204922742657',['door-closed-locked']='rbxassetid://74027613267551',['door-closed']='rbxassetid://136249099949073',['door-open']='rbxassetid://91306356501736',dot='rbxassetid://137321056643916',download='rbxassetid://134814648082393',['drafting-compass']='rbxassetid://99701976182841',drama='rbxassetid://110297795801577',dribbble='rbxassetid://80231809663849',drill='rbxassetid://108644821412796',drone='rbxassetid://117299095794783',['droplet-off']='rbxassetid://119365002225172',droplet='rbxassetid://100597455015098',droplets='rbxassetid://140111846025180',drum='rbxassetid://136979060344890',drumstick='rbxassetid://104662462521709',dumbbell='rbxassetid://80277236776212',['ear-off']='rbxassetid://87421916192807',ear='rbxassetid://121894949934209',['earth-lock']='rbxassetid://88814147073745',earth='rbxassetid://76231597751076',eclipse='rbxassetid://114829622118222',['egg-fried']='rbxassetid://90622538210545',['egg-off']='rbxassetid://92288321309285',egg='rbxassetid://117851493400222',['ellipsis-vertical']='rbxassetid://117978708573781',ellipsis='rbxassetid://140019550645825',['equal-approximately']='rbxassetid://105382689698323',['equal-not']='rbxassetid://76864449458032',equal='rbxassetid://123467780715624',eraser='rbxassetid://133957773112410',['ethernet-port']='rbxassetid://75391715149314',euro='rbxassetid://72229646524456',['ev-charger']='rbxassetid://97906158859623',expand='rbxassetid://137492887754537',['external-link']='rbxassetid://129331830773832',['eye-closed']='rbxassetid://111063268625789',['eye-off']='rbxassetid://135928786788378',eye='rbxassetid://100033680381365',facebook='rbxassetid://72098528632192',factory='rbxassetid://102170024318039',fan='rbxassetid://78391400440696',['fast-forward']='rbxassetid://121615540167909',feather='rbxassetid://91872927606406',fence='rbxassetid://123451565578029',['ferris-wheel']='rbxassetid://79729205796176',figma='rbxassetid://134182122852301',['file-archive']='rbxassetid://77018106869967',['file-axis-3d']='rbxassetid://133912328009885',['file-badge']='rbxassetid://74564895394477',['file-box']='rbxassetid://119264004071690',['file-braces-corner']='rbxassetid://77253337986109',['file-braces']='rbxassetid://95314128621234',['file-chart-column-increasing']='rbxassetid://134449481172067',['file-chart-column']='rbxassetid://82048481252560',['file-chart-line']='rbxassetid://71954360551345',['file-chart-pie']='rbxassetid://81072193564497',['file-check-corner']='rbxassetid://76295552859171',['file-check']='rbxassetid://82604001452455',['file-clock']='rbxassetid://102325208830990',['file-code-corner']='rbxassetid://78293841184371',['file-code']='rbxassetid://130978036895504',['file-cog']='rbxassetid://101385347151368',['file-diff']='rbxassetid://96147216772241',['file-digit']='rbxassetid://89220220354580',['file-down']='rbxassetid://120650154178290',['file-exclamation-point']='rbxassetid://102821865889635',['file-headphone']='rbxassetid://100533735901986',['file-heart']='rbxassetid://132214916401696',['file-image']='rbxassetid://123334057511782',['file-input']='rbxassetid://124728604166044',['file-key']='rbxassetid://118790255921100',['file-lock']='rbxassetid://72170228691242',['file-minus-corner']='rbxassetid://119263271735124',['file-minus']='rbxassetid://111014798459222',['file-music']='rbxassetid://134948051536671',['file-output']='rbxassetid://92146832572911',['file-pen-line']='rbxassetid://104622936345006',['file-pen']='rbxassetid://79556179730240',['file-play']='rbxassetid://89006821567838',['file-plus-corner']='rbxassetid://76544604043974',['file-plus']='rbxassetid://78881710800060',['file-question-mark']='rbxassetid://127617422859576',['file-scan']='rbxassetid://129480105228213',['file-search-corner']='rbxassetid://90974165234008',['file-search']='rbxassetid://97780235974933',['file-signal']='rbxassetid://122070252538165',['file-sliders']='rbxassetid://85787771732439',['file-spreadsheet']='rbxassetid://134501869359270',['file-stack']='rbxassetid://138929929862605',['file-symlink']='rbxassetid://91865722036510',['file-terminal']='rbxassetid://116757454755476',['file-text']='rbxassetid://90496405707281',['file-type-corner']='rbxassetid://124902230275209',['file-type']='rbxassetid://115272552799361',['file-up']='rbxassetid://131173039312748',['file-user']='rbxassetid://99552018455009',['file-video-camera']='rbxassetid://81719056173960',['file-volume']='rbxassetid://111264764438958',['file-x-corner']='rbxassetid://87554136773609',['file-x']='rbxassetid://107333775515154',file='rbxassetid://74748492079329',files='rbxassetid://102806336233202',film='rbxassetid://120978945609706',fingerprint='rbxassetid://112173305232811',['fire-extinguisher']='rbxassetid://111643493006960',['fish-off']='rbxassetid://89756724887508',['fish-symbol']='rbxassetid://118475177681618',fish='rbxassetid://124360663785796',['flag-off']='rbxassetid://112944528856799',['flag-triangle-left']='rbxassetid://88045221285272',['flag-triangle-right']='rbxassetid://108292480304566',flag='rbxassetid://78183383236196',['flame-kindling']='rbxassetid://139728976917928',flame='rbxassetid://98218034436456',['flashlight-off']='rbxassetid://79780362871740',flashlight='rbxassetid://100286985600444',['flask-conical-off']='rbxassetid://112597970025298',['flask-conical']='rbxassetid://128406680901165',['flask-round']='rbxassetid://127508287324940',['flip-horizontal-2']='rbxassetid://103726993598186',['flip-horizontal']='rbxassetid://122937530107837',['flip-vertical-2']='rbxassetid://103836358956328',['flip-vertical']='rbxassetid://108003917346888',['flower-2']='rbxassetid://72934574245145',flower='rbxassetid://86129438272762',focus='rbxassetid://87493973153317',['fold-horizontal']='rbxassetid://92835712442240',['fold-vertical']='rbxassetid://108873727253656',['folder-archive']='rbxassetid://97312009460206',['folder-check']='rbxassetid://128492920904557',['folder-clock']='rbxassetid://111964836738545',['folder-closed']='rbxassetid://118286209350843',['folder-code']='rbxassetid://70624096349370',['folder-cog']='rbxassetid://85299519462846',['folder-dot']='rbxassetid://138687772725278',['folder-down']='rbxassetid://118044108459225',['folder-git-2']='rbxassetid://101394054141166',['folder-git']='rbxassetid://121885778095158',['folder-heart']='rbxassetid://79104747211105',['folder-input']='rbxassetid://90699920697871',['folder-kanban']='rbxassetid://78313285104072',['folder-key']='rbxassetid://85270407596791',['folder-lock']='rbxassetid://119201572260567',['folder-minus']='rbxassetid://85648718999010',['folder-open-dot']='rbxassetid://74741494767354',['folder-open']='rbxassetid://76018996254888',['folder-output']='rbxassetid://101532447937612',['folder-pen']='rbxassetid://112770491173911',['folder-plus']='rbxassetid://91865663406119',['folder-root']='rbxassetid://103333751154693',['folder-search-2']='rbxassetid://71276453442655',['folder-search']='rbxassetid://110568075123861',['folder-symlink']='rbxassetid://127485747227189',['folder-sync']='rbxassetid://91544602659796',['folder-tree']='rbxassetid://85577554337861',['folder-up']='rbxassetid://72008269765857',['folder-x']='rbxassetid://91699618247635',folder='rbxassetid://80846616596607',folders='rbxassetid://110351216219061',footprints='rbxassetid://139192589041315',forklift='rbxassetid://72030930983101',forward='rbxassetid://97545944739523',frame='rbxassetid://109080612832751',framer='rbxassetid://108384807262391',frown='rbxassetid://124407301067982',fuel='rbxassetid://106447647274511',fullscreen='rbxassetid://77793665526178',['funnel-plus']='rbxassetid://100780233821928',['funnel-x']='rbxassetid://70984385812555',funnel='rbxassetid://108829540827529',['gallery-horizontal-end']='rbxassetid://74672430161161',['gallery-horizontal']='rbxassetid://80004001442122',['gallery-thumbnails']='rbxassetid://136219289862706',['gallery-vertical-end']='rbxassetid://106461402088317',['gallery-vertical']='rbxassetid://119299431466725',['gamepad-2']='rbxassetid://92483947987410',['gamepad-directional']='rbxassetid://84342305212226',gamepad='rbxassetid://121607283959010',gauge='rbxassetid://110273524101447',gavel='rbxassetid://78952298198456',gem='rbxassetid://112904952151156',['georgian-lari']='rbxassetid://98084432591687',ghost='rbxassetid://113822048130017',gift='rbxassetid://109855212076373',['git-branch-minus']='rbxassetid://97385010649411',['git-branch-plus']='rbxassetid://125944221134316',['git-branch']='rbxassetid://90490195516649',['git-commit-horizontal']='rbxassetid://133646041800147',['git-commit-vertical']='rbxassetid://122098032990350',['git-compare-arrows']='rbxassetid://84874426520216',['git-compare']='rbxassetid://91945124438792',['git-fork']='rbxassetid://89954992404765',['git-graph']='rbxassetid://86166832019304',['git-merge']='rbxassetid://131833355158059',['git-pull-request-arrow']='rbxassetid://94507974577439',['git-pull-request-closed']='rbxassetid://78070600389091',['git-pull-request-create-arrow']='rbxassetid://127422677061091',['git-pull-request-create']='rbxassetid://105929577383926',['git-pull-request-draft']='rbxassetid://76173459869943',['git-pull-request']='rbxassetid://138463010991471',github='rbxassetid://120349554354380',gitlab='rbxassetid://114054627192933',['glass-water']='rbxassetid://115526102400988',glasses='rbxassetid://87936407455373',['globe-lock']='rbxassetid://134065526704402',globe='rbxassetid://114238209622913',goal='rbxassetid://120517954878160',gpu='rbxassetid://95577823614219',['graduation-cap']='rbxassetid://93771896340220',grape='rbxassetid://134760640415561',['grid-2x2-check']='rbxassetid://138468840220821',['grid-2x2-plus']='rbxassetid://91811610580247',['grid-2x2-x']='rbxassetid://72407303981388',['grid-2x2']='rbxassetid://99050491897640',['grid-3x2']='rbxassetid://95528684210010',['grid-3x3']='rbxassetid://70419024781206',['grip-horizontal']='rbxassetid://136255899715930',['grip-vertical']='rbxassetid://137183678565296',grip='rbxassetid://109058783556768',group='rbxassetid://107643418926671',guitar='rbxassetid://75915531867926',ham='rbxassetid://74465607934635',hamburger='rbxassetid://93086916815495',hammer='rbxassetid://83545120140895',['hand-coins']='rbxassetid://126990543175462',['hand-fist']='rbxassetid://83341608917591',['hand-grab']='rbxassetid://88867162163985',['hand-heart']='rbxassetid://117507367668412',['hand-helping']='rbxassetid://89897738419446',['hand-metal']='rbxassetid://113619498548713',['hand-platter']='rbxassetid://88594727743168',hand='rbxassetid://130703864968637',handbag='rbxassetid://135675846264061',handshake='rbxassetid://78442115255814',['hard-drive-download']='rbxassetid://73913801230614',['hard-drive-upload']='rbxassetid://85762133615118',['hard-drive']='rbxassetid://88183305858463',['hard-hat']='rbxassetid://128050846767382',hash='rbxassetid://82890331678520',['hat-glasses']='rbxassetid://101165538224815',haze='rbxassetid://108857561768901',['hdmi-port']='rbxassetid://103693661037020',['heading-1']='rbxassetid://118129315662110',['heading-2']='rbxassetid://110209069670094',['heading-3']='rbxassetid://90267885237062',['heading-4']='rbxassetid://129625620307602',['heading-5']='rbxassetid://120386663181267',['heading-6']='rbxassetid://90959079775093',heading='rbxassetid://129254312067735',['headphone-off']='rbxassetid://85038251615641',headphones='rbxassetid://118833729589183',headset='rbxassetid://129269236787694',['heart-crack']='rbxassetid://110987638564119',['heart-handshake']='rbxassetid://111483078692002',['heart-minus']='rbxassetid://96827380163326',['heart-off']='rbxassetid://89748414415617',['heart-plus']='rbxassetid://94877796283249',['heart-pulse']='rbxassetid://129352925579546',heart='rbxassetid://116559368303288',heater='rbxassetid://140478466880916',helicopter='rbxassetid://111557171735930',hexagon='rbxassetid://127592089339199',highlighter='rbxassetid://77411555641113',history='rbxassetid://123980022019922',['hop-off']='rbxassetid://103386036934034',hop='rbxassetid://82778923997672',hospital='rbxassetid://105868763850707',hotel='rbxassetid://132283390859718',hourglass='rbxassetid://86160434939203',['house-heart']='rbxassetid://136054771868597',['house-plug']='rbxassetid://71438263712075',['house-plus']='rbxassetid://118495165208309',['house-wifi']='rbxassetid://126495519725698',house='rbxassetid://98755624629571',['ice-cream-bowl']='rbxassetid://124867218454386',['ice-cream-cone']='rbxassetid://90751397288639',['id-card-lanyard']='rbxassetid://90761480469224',['id-card']='rbxassetid://75354294622640',['image-down']='rbxassetid://78972295741235',['image-minus']='rbxassetid://101066016918565',['image-off']='rbxassetid://81934811700938',['image-play']='rbxassetid://129501806784210',['image-plus']='rbxassetid://70391970623917',['image-up']='rbxassetid://126610009605241',['image-upscale']='rbxassetid://106963545024679',images='rbxassetid://79350649395557',import='rbxassetid://116545008906029',inbox='rbxassetid://112591360302868',['indian-rupee']='rbxassetid://113038778381805',infinity='rbxassetid://98083086936965',info='rbxassetid://124560466474914',['inspection-panel']='rbxassetid://70905313146088',instagram='rbxassetid://119864798614855',italic='rbxassetid://96220378864282',['iteration-ccw']='rbxassetid://140221832794083',['iteration-cw']='rbxassetid://95534489554662',['japanese-yen']='rbxassetid://106362863465813',joystick='rbxassetid://99416790224739',kanban='rbxassetid://125934100055431',kayak='rbxassetid://136107544609389',['key-round']='rbxassetid://83619031955390',['key-square']='rbxassetid://94621420033649',key='rbxassetid://96510194465420',['keyboard-music']='rbxassetid://121058541758636',['keyboard-off']='rbxassetid://92466375369772',keyboard='rbxassetid://121474456068237',['lamp-ceiling']='rbxassetid://80032758469141',['lamp-desk']='rbxassetid://85290686983238',['lamp-floor']='rbxassetid://104585881375892',['lamp-wall-down']='rbxassetid://91271394132073',['lamp-wall-up']='rbxassetid://132141464337445',lamp='rbxassetid://110730830653382',['land-plot']='rbxassetid://96449039620294',landmark='rbxassetid://76885079756393',languages='rbxassetid://90816903776498',['laptop-minimal-check']='rbxassetid://114352019833865',['laptop-minimal']='rbxassetid://136705765566068',laptop='rbxassetid://111387063244975',['lasso-select']='rbxassetid://105609719912753',lasso='rbxassetid://121072936884007',laugh='rbxassetid://104491311361166',['layers-2']='rbxassetid://70536710516357',layers='rbxassetid://81973586053257',['layout-dashboard']='rbxassetid://139929981863901',['layout-grid']='rbxassetid://81344910161871',['layout-list']='rbxassetid://87462136296578',['layout-panel-left']='rbxassetid://125092469751491',['layout-panel-top']='rbxassetid://91943941515944',['layout-template']='rbxassetid://115564446417985',leaf='rbxassetid://119951075637174',['leafy-green']='rbxassetid://105146290493154',lectern='rbxassetid://106166425183862',['library-big']='rbxassetid://106794530191412',library='rbxassetid://114334671982047',['life-buoy']='rbxassetid://81168450671956',ligature='rbxassetid://111397873269411',['lightbulb-off']='rbxassetid://83795722296178',lightbulb='rbxassetid://103871245626488',['line-squiggle']='rbxassetid://109555164424447',['link-2-off']='rbxassetid://76885956296867',['link-2']='rbxassetid://86072351557466',link='rbxassetid://131607023382430',linkedin='rbxassetid://132842789255788',['list-check']='rbxassetid://72374358471156',['list-checks']='rbxassetid://99809353635593',['list-chevrons-down-up']='rbxassetid://137409641500711',['list-chevrons-up-down']='rbxassetid://81825351389084',['list-collapse']='rbxassetid://124505247702401',['list-end']='rbxassetid://77650610048119',['list-filter-plus']='rbxassetid://96385120752336',['list-filter']='rbxassetid://103321376129527',['list-indent-decrease']='rbxassetid://137879979228193',['list-indent-increase']='rbxassetid://79051053161201',['list-minus']='rbxassetid://138507965142671',['list-music']='rbxassetid://126380635781840',['list-ordered']='rbxassetid://83212528113913',['list-plus']='rbxassetid://112384738137814',['list-restart']='rbxassetid://91703153577421',['list-start']='rbxassetid://84828348299727',['list-todo']='rbxassetid://132980603752108',['list-tree']='rbxassetid://97685396239010',['list-video']='rbxassetid://93648525452489',['list-x']='rbxassetid://113025303988861',list='rbxassetid://113179976918783',['loader-circle']='rbxassetid://116535712789945',['loader-pinwheel']='rbxassetid://108513357940900',loader='rbxassetid://78408734580845',['locate-fixed']='rbxassetid://137367361548433',['locate-off']='rbxassetid://73729216338137',locate='rbxassetid://84467676590391',['lock-keyhole-open']='rbxassetid://110863509313073',['lock-keyhole']='rbxassetid://78672912777756',['lock-open']='rbxassetid://93597915325122',lock='rbxassetid://134724289526879',['log-in']='rbxassetid://103768533135201',['log-out']='rbxassetid://84895399304975',logs='rbxassetid://89772091251787',lollipop='rbxassetid://84681611583044',luggage='rbxassetid://76619236486400',magnet='rbxassetid://135162361226972',['mail-check']='rbxassetid://86921536259917',['mail-minus']='rbxassetid://81989813236553',['mail-open']='rbxassetid://122785416858638',['mail-plus']='rbxassetid://104886401588341',['mail-question-mark']='rbxassetid://126540170949819',['mail-search']='rbxassetid://135616173775287',['mail-warning']='rbxassetid://81495303676089',['mail-x']='rbxassetid://74607841705644',mail='rbxassetid://103945161245599',mailbox='rbxassetid://82765503320335',mails='rbxassetid://90673453450080',['map-minus']='rbxassetid://129525760577747',['map-pin-check-inside']='rbxassetid://107130529843809',['map-pin-check']='rbxassetid://118110914690154',['map-pin-house']='rbxassetid://80546885029816',['map-pin-minus-inside']='rbxassetid://79005529692964',['map-pin-minus']='rbxassetid://74518762643623',['map-pin-off']='rbxassetid://82474689391020',['map-pin-pen']='rbxassetid://113515395277504',['map-pin-plus-inside']='rbxassetid://134639656514430',['map-pin-plus']='rbxassetid://91875228967029',['map-pin-x-inside']='rbxassetid://126235934252379',['map-pin-x']='rbxassetid://101085273547316',['map-pin']='rbxassetid://84279202219901',['map-pinned']='rbxassetid://103963788475034',['map-plus']='rbxassetid://129388826743495',map='rbxassetid://95107167260947',['mars-stroke']='rbxassetid://131973193186828',mars='rbxassetid://111287112372511',martini='rbxassetid://82977695401058',['maximize-2']='rbxassetid://73085922906397',maximize='rbxassetid://76045941763188',medal='rbxassetid://79016002264450',['megaphone-off']='rbxassetid://124280774193935',megaphone='rbxassetid://118759541854879',meh='rbxassetid://132197867028557',['memory-stick']='rbxassetid://93212591343119',menu='rbxassetid://77021539815611',merge='rbxassetid://126201866476775',['message-circle-code']='rbxassetid://112865244991651',['message-circle-dashed']='rbxassetid://81525157881897',['message-circle-heart']='rbxassetid://101990756073677',['message-circle-more']='rbxassetid://92856823884663',['message-circle-off']='rbxassetid://134955643890328',['message-circle-plus']='rbxassetid://106562979649273',['message-circle-question-mark']='rbxassetid://107700302759934',['message-circle-reply']='rbxassetid://137071749508334',['message-circle-warning']='rbxassetid://119020096067894',['message-circle-x']='rbxassetid://126843387725536',['message-circle']='rbxassetid://127255077587058',['message-square-code']='rbxassetid://110968863152123',['message-square-dashed']='rbxassetid://107653455516238',['message-square-diff']='rbxassetid://75472190472625',['message-square-dot']='rbxassetid://127806382463916',['message-square-heart']='rbxassetid://75612811742074',['message-square-lock']='rbxassetid://81268215619563',['message-square-more']='rbxassetid://120139782405970',['message-square-off']='rbxassetid://99961019005789',['message-square-plus']='rbxassetid://76934450256199',['message-square-quote']='rbxassetid://116670768629340',['message-square-reply']='rbxassetid://130985622754637',['message-square-share']='rbxassetid://131017005324026',['message-square-text']='rbxassetid://94899503194205',['message-square-warning']='rbxassetid://138432903962261',['message-square-x']='rbxassetid://137285463279462',['message-square']='rbxassetid://83881670383280',['messages-square']='rbxassetid://97532166733358',['mic-off']='rbxassetid://82123034444822',['mic-vocal']='rbxassetid://99082286164362',mic='rbxassetid://89640799126523',microchip='rbxassetid://73937907669903',microscope='rbxassetid://116875530102782',microwave='rbxassetid://108411735353008',milestone='rbxassetid://101618292325920',['milk-off']='rbxassetid://72388480962742',milk='rbxassetid://96221903896918',['minimize-2']='rbxassetid://116269596042539',minimize='rbxassetid://121304296213645',minus='rbxassetid://118026365011536',['monitor-check']='rbxassetid://86651948439229',['monitor-cloud']='rbxassetid://85931096038318',['monitor-cog']='rbxassetid://94345128715799',['monitor-dot']='rbxassetid://130394010063680',['monitor-down']='rbxassetid://97466933743423',['monitor-off']='rbxassetid://74395526657953',['monitor-pause']='rbxassetid://76002184067562',['monitor-play']='rbxassetid://133018824306217',['monitor-smartphone']='rbxassetid://84335680433378',['monitor-speaker']='rbxassetid://81744810060380',['monitor-stop']='rbxassetid://98708958984757',['monitor-up']='rbxassetid://96035360858377',['monitor-x']='rbxassetid://126265210441423',monitor='rbxassetid://72664649203050',['moon-star']='rbxassetid://82782200506348',moon='rbxassetid://83380517901735',motorbike='rbxassetid://94580787368233',['mountain-snow']='rbxassetid://105315495740588',mountain='rbxassetid://73269957566415',['mouse-off']='rbxassetid://75267871697595',['mouse-pointer-2-off']='rbxassetid://104701076865632',['mouse-pointer-2']='rbxassetid://117093892862228',['mouse-pointer-ban']='rbxassetid://106849413057133',['mouse-pointer-click']='rbxassetid://107150227368485',['mouse-pointer']='rbxassetid://72322454962935',mouse='rbxassetid://73096068864710',['move-3d']='rbxassetid://103365982054003',['move-diagonal-2']='rbxassetid://117298577948096',['move-diagonal']='rbxassetid://101433481954184',['move-down-left']='rbxassetid://102819433534567',['move-down-right']='rbxassetid://101479760041877',['move-down']='rbxassetid://70510115135583',['move-horizontal']='rbxassetid://88513523439149',['move-left']='rbxassetid://137614740247980',['move-right']='rbxassetid://132455779472989',['move-up-left']='rbxassetid://139079815540148',['move-up-right']='rbxassetid://105885140592646',['move-up']='rbxassetid://84505444262658',['move-vertical']='rbxassetid://86234730730899',move='rbxassetid://116138709011735',['music-2']='rbxassetid://134397426600888',['music-3']='rbxassetid://94466120066498',['music-4']='rbxassetid://132459323665838',music='rbxassetid://113343203848535',['navigation-2-off']='rbxassetid://116569611780763',['navigation-2']='rbxassetid://81889066747907',['navigation-off']='rbxassetid://87003270290777',navigation='rbxassetid://79308213542922',network='rbxassetid://127410729922644',newspaper='rbxassetid://123479530460544',nfc='rbxassetid://76822396542242',['non-binary']='rbxassetid://78442360386235',['notebook-pen']='rbxassetid://140380614761023',['notebook-tabs']='rbxassetid://127371085570083',['notebook-text']='rbxassetid://93061585217270',notebook='rbxassetid://136132108664987',['notepad-text-dashed']='rbxassetid://135793446376219',['notepad-text']='rbxassetid://93404682958966',['nut-off']='rbxassetid://78795397311573',nut='rbxassetid://127146410705656',['octagon-alert']='rbxassetid://140438367956051',['octagon-minus']='rbxassetid://74720436795421',['octagon-pause']='rbxassetid://103161463909039',['octagon-x']='rbxassetid://90498161006311',octagon='rbxassetid://120803515514852',omega='rbxassetid://70414080018786',option='rbxassetid://100776883894054',orbit='rbxassetid://108926136860562',origami='rbxassetid://136020626667101',['package-2']='rbxassetid://70394974762575',['package-check']='rbxassetid://102374216055130',['package-minus']='rbxassetid://114492858789692',['package-open']='rbxassetid://132890233237818',['package-plus']='rbxassetid://129261988138366',['package-search']='rbxassetid://95465120894145',['package-x']='rbxassetid://70818501607442',package='rbxassetid://97261141732706',['paint-bucket']='rbxassetid://124275586663284',['paint-roller']='rbxassetid://115248074358348',['paintbrush-vertical']='rbxassetid://105151296591292',paintbrush='rbxassetid://125572663700289',palette='rbxassetid://86350350950064',panda='rbxassetid://132509022802512',['panel-bottom-close']='rbxassetid://74287004071159',['panel-bottom-dashed']='rbxassetid://131084651621603',['panel-bottom-open']='rbxassetid://107768659586540',['panel-bottom']='rbxassetid://132127145048511',['panel-left-close']='rbxassetid://126579818823552',['panel-left-dashed']='rbxassetid://75536606374585',['panel-left-open']='rbxassetid://111075816195767',['panel-left-right-dashed']='rbxassetid://110100707973959',['panel-left']='rbxassetid://97419752870313',['panel-right-close']='rbxassetid://139528655524132',['panel-right-dashed']='rbxassetid://94959793877311',['panel-right-open']='rbxassetid://118114419142794',['panel-right']='rbxassetid://116365035443156',['panel-top-bottom-dashed']='rbxassetid://134737235653344',['panel-top-close']='rbxassetid://83578325777808',['panel-top-dashed']='rbxassetid://70522913169237',['panel-top-open']='rbxassetid://137959875507454',['panel-top']='rbxassetid://75838479462875',['panels-left-bottom']='rbxassetid://72996856149149',['panels-right-bottom']='rbxassetid://90659068960726',['panels-top-left']='rbxassetid://79858853850600',paperclip='rbxassetid://92088291163453',parentheses='rbxassetid://78950955173096',['parking-meter']='rbxassetid://84652733960568',['party-popper']='rbxassetid://111626795712193',pause='rbxassetid://74873705394436',['paw-print']='rbxassetid://112218825427601',['pc-case']='rbxassetid://122978648019101',['pen-line']='rbxassetid://109108135755303',['pen-off']='rbxassetid://84807123119438',['pen-tool']='rbxassetid://106145404953445',pen='rbxassetid://72037878096321',['pencil-line']='rbxassetid://88392917053533',['pencil-off']='rbxassetid://103330927652832',['pencil-ruler']='rbxassetid://110120288284597',pencil='rbxassetid://137986121120732',pentagon='rbxassetid://79184802179890',percent='rbxassetid://130155041032013',['person-standing']='rbxassetid://125020872044147',['philippine-peso']='rbxassetid://91173798254675',['phone-call']='rbxassetid://70555587592860',['phone-forwarded']='rbxassetid://113269614319737',['phone-incoming']='rbxassetid://82863576359288',['phone-missed']='rbxassetid://130156165198376',['phone-off']='rbxassetid://133318623553383',['phone-outgoing']='rbxassetid://104576478735825',phone='rbxassetid://128804946640049',pi='rbxassetid://74936036243146',piano='rbxassetid://85008880789520',pickaxe='rbxassetid://105888023317688',['picture-in-picture-2']='rbxassetid://112803319544468',['picture-in-picture']='rbxassetid://80579597835123',['piggy-bank']='rbxassetid://79498575790721',['pilcrow-left']='rbxassetid://103803000849583',['pilcrow-right']='rbxassetid://104881733911870',pilcrow='rbxassetid://139512780392871',['pill-bottle']='rbxassetid://118394692404597',pill='rbxassetid://73280534813448',['pin-off']='rbxassetid://127696372451750',pin='rbxassetid://120978111007514',pipette='rbxassetid://133167932934404',pizza='rbxassetid://126964453193501',['plane-landing']='rbxassetid://122555692211889',['plane-takeoff']='rbxassetid://117179478829575',plane='rbxassetid://126985561580989',play='rbxassetid://135609604299893',['plug-2']='rbxassetid://97912386476366',['plug-zap']='rbxassetid://74506269884055',plug='rbxassetid://99782373064495',plus='rbxassetid://111774323017047',['pocket-knife']='rbxassetid://134075428063965',pocket='rbxassetid://136686762542964',podcast='rbxassetid://109577075549215',['pointer-off']='rbxassetid://95488389312794',pointer='rbxassetid://92615117311099',popcorn='rbxassetid://139446511232750',popsicle='rbxassetid://112696318077073',['pound-sterling']='rbxassetid://127482649469130',['power-off']='rbxassetid://118768311012214',power='rbxassetid://96479131758775',presentation='rbxassetid://106134583757890',['printer-check']='rbxassetid://130273549443689',printer='rbxassetid://76080649734247',projector='rbxassetid://103281856385283',proportions='rbxassetid://130046855997237',puzzle='rbxassetid://136837798892463',pyramid='rbxassetid://107811442374127',['qr-code']='rbxassetid://105329945723350',quote='rbxassetid://103271711590001',rabbit='rbxassetid://98580518804206',radar='rbxassetid://138528222906635',radiation='rbxassetid://104499586848433',radical='rbxassetid://132758286926047',['radio-receiver']='rbxassetid://129598303378835',['radio-tower']='rbxassetid://93958663130054',radio='rbxassetid://85611589536956',radius='rbxassetid://89814505307129',['rail-symbol']='rbxassetid://134295386306962',rainbow='rbxassetid://132488862841895',rat='rbxassetid://127400975953159',ratio='rbxassetid://126369423897295',['receipt-cent']='rbxassetid://91557573925201',['receipt-euro']='rbxassetid://94015722210295',['receipt-indian-rupee']='rbxassetid://89718170439990',['receipt-japanese-yen']='rbxassetid://132472560758851',['receipt-pound-sterling']='rbxassetid://73934967569625',['receipt-russian-ruble']='rbxassetid://105164576936853',['receipt-swiss-franc']='rbxassetid://72503668620116',['receipt-text']='rbxassetid://138483536013737',['receipt-turkish-lira']='rbxassetid://91950765836342',receipt='rbxassetid://77877895901792',['rectangle-circle']='rbxassetid://100642423153903',['rectangle-ellipsis']='rbxassetid://112919953980965',['rectangle-goggles']='rbxassetid://98605436666727',['rectangle-horizontal']='rbxassetid://90224199814966',['rectangle-vertical']='rbxassetid://117277050590967',recycle='rbxassetid://140417023381961',['redo-2']='rbxassetid://70451039017914',['redo-dot']='rbxassetid://94252981719732',redo='rbxassetid://116150342119054',['refresh-ccw-dot']='rbxassetid://106702246753270',['refresh-ccw']='rbxassetid://117913330389477',['refresh-cw-off']='rbxassetid://140179498843054',['refresh-cw']='rbxassetid://138133190015277',refrigerator='rbxassetid://102614042652753',regex='rbxassetid://100727200791841',['remove-formatting']='rbxassetid://112833162022628',['repeat-1']='rbxassetid://130144534857095',['repeat-2']='rbxassetid://85927537182704',['repeat']='rbxassetid://121886242955173',['replace-all']='rbxassetid://127862728198635',replace='rbxassetid://128404082279430',['reply-all']='rbxassetid://71723137343562',reply='rbxassetid://109788633497028',rewind='rbxassetid://95205297521988',ribbon='rbxassetid://94265331526851',rocket='rbxassetid://87412317685854',['rocking-chair']='rbxassetid://110420269495360',['roller-coaster']='rbxassetid://112426178972099',rose='rbxassetid://126336840238769',['rotate-3d']='rbxassetid://76300551576392',['rotate-ccw-key']='rbxassetid://74976035240976',['rotate-ccw-square']='rbxassetid://90515853170424',['rotate-ccw']='rbxassetid://110116685948665',['rotate-cw-square']='rbxassetid://77095448159303',['rotate-cw']='rbxassetid://84183336178654',['route-off']='rbxassetid://106350402024079',route='rbxassetid://89968303228953',router='rbxassetid://102130331994471',['rows-2']='rbxassetid://112556185960101',['rows-3']='rbxassetid://117215586961375',['rows-4']='rbxassetid://125646021959055',rss='rbxassetid://131789058984793',['ruler-dimension-line']='rbxassetid://70673861371412',ruler='rbxassetid://81432445547423',['russian-ruble']='rbxassetid://126357936542156',sailboat='rbxassetid://87110567187540',salad='rbxassetid://128864507821603',sandwich='rbxassetid://104573187458917',['satellite-dish']='rbxassetid://136742443888305',satellite='rbxassetid://134967053164645',['saudi-riyal']='rbxassetid://102282769104635',['save-all']='rbxassetid://116946975799440',['save-off']='rbxassetid://87085435778560',save='rbxassetid://126116963775616',['scale-3d']='rbxassetid://72414199620352',scale='rbxassetid://108203682317477',scaling='rbxassetid://122360365318466',['scan-barcode']='rbxassetid://96889457154761',['scan-eye']='rbxassetid://99244790601968',['scan-face']='rbxassetid://109959345069668',['scan-heart']='rbxassetid://106280819776142',['scan-line']='rbxassetid://126544908146540',['scan-qr-code']='rbxassetid://105409149549927',['scan-search']='rbxassetid://80009010551347',['scan-text']='rbxassetid://73702396787766',scan='rbxassetid://123104789658180',school='rbxassetid://76351530290068',['scissors-line-dashed']='rbxassetid://122237447974173',scissors='rbxassetid://118665510911274',['screen-share-off']='rbxassetid://107677572669805',['screen-share']='rbxassetid://85137895705653',['scroll-text']='rbxassetid://97321022666868',scroll='rbxassetid://74072101474951',['search-check']='rbxassetid://75442076191356',['search-code']='rbxassetid://117114794592802',['search-slash']='rbxassetid://96483932261041',['search-x']='rbxassetid://137319957522951',search='rbxassetid://121018724060431',section='rbxassetid://91732188298948',['send-horizontal']='rbxassetid://111734392411664',['send-to-back']='rbxassetid://75340312862253',send='rbxassetid://127751956873796',['separator-horizontal']='rbxassetid://84864453699927',['separator-vertical']='rbxassetid://84031801478581',['server-cog']='rbxassetid://138470287250966',['server-crash']='rbxassetid://132810618000212',['server-off']='rbxassetid://114048751507723',server='rbxassetid://92188766517878',['settings-2']='rbxassetid://135684703553372',settings='rbxassetid://80758916183665',shapes='rbxassetid://129989433311409',['share-2']='rbxassetid://71210767962065',share='rbxassetid://87340985053299',sheet='rbxassetid://134902122480171',shell='rbxassetid://140212943563599',['shield-alert']='rbxassetid://114995877719925',['shield-ban']='rbxassetid://108765041044649',['shield-check']='rbxassetid://87354736164608',['shield-ellipsis']='rbxassetid://114794739892123',['shield-half']='rbxassetid://117842634172647',['shield-minus']='rbxassetid://89965059528921',['shield-off']='rbxassetid://133426959132690',['shield-plus']='rbxassetid://100664857995498',['shield-question-mark']='rbxassetid://135722075265150',['shield-user']='rbxassetid://124832775645347',['shield-x']='rbxassetid://73370117343811',shield='rbxassetid://110987169760162',['ship-wheel']='rbxassetid://130797795829448',ship='rbxassetid://83995100553930',shirt='rbxassetid://106579555405966',['shopping-bag']='rbxassetid://71885477293226',['shopping-basket']='rbxassetid://138646411956433',['shopping-cart']='rbxassetid://128420521375441',shovel='rbxassetid://102465000512056',['shower-head']='rbxassetid://75884944024117',shredder='rbxassetid://122125164414463',shrimp='rbxassetid://102625900815307',shrink='rbxassetid://90953687918880',shrub='rbxassetid://127326280714343',shuffle='rbxassetid://132382786975101',sigma='rbxassetid://126884244870899',['signal-high']='rbxassetid://130436670012270',['signal-low']='rbxassetid://73674683500458',['signal-medium']='rbxassetid://125003021367019',['signal-zero']='rbxassetid://130045332414754',signal='rbxassetid://78424889355261',signature='rbxassetid://114402748013000',['signpost-big']='rbxassetid://115780185675001',signpost='rbxassetid://106584743791433',siren='rbxassetid://134210267818039',['skip-back']='rbxassetid://70466132711334',['skip-forward']='rbxassetid://124844823753990',skull='rbxassetid://137726256442333',slack='rbxassetid://96089719516736',slash='rbxassetid://117792185664263',slice='rbxassetid://95810504278179',['sliders-horizontal']='rbxassetid://85538382643347',['sliders-vertical']='rbxassetid://101190569086853',['smartphone-charging']='rbxassetid://102837532613995',['smartphone-nfc']='rbxassetid://82326425754446',smartphone='rbxassetid://96623008834511',['smile-plus']='rbxassetid://131981881472144',smile='rbxassetid://105880397565283',snail='rbxassetid://70904536548363',snowflake='rbxassetid://101235206534566',['soap-dispenser-droplet']='rbxassetid://77258480479465',sofa='rbxassetid://114427687218324',['solar-panel']='rbxassetid://132448188047921',soup='rbxassetid://115092551871618',space='rbxassetid://87072088914178',spade='rbxassetid://131444449466462',sparkle='rbxassetid://111044800239623',sparkles='rbxassetid://138635884129147',speaker='rbxassetid://96227183003618',speech='rbxassetid://87013139446349',['spell-check-2']='rbxassetid://81556731785534',['spell-check']='rbxassetid://91913483031334',['spline-pointer']='rbxassetid://84842840956804',spline='rbxassetid://129406685807412',split='rbxassetid://105112438805988',spool='rbxassetid://124541981347743',spotlight='rbxassetid://77571742539344',['spray-can']='rbxassetid://128372039366326',sprout='rbxassetid://100091687832508',['square-activity']='rbxassetid://89496630185293',['square-arrow-down-left']='rbxassetid://108194680296901',['square-arrow-down-right']='rbxassetid://99403846801050',['square-arrow-down']='rbxassetid://135962519626588',['square-arrow-left']='rbxassetid://111671474549238',['square-arrow-out-down-left']='rbxassetid://125714881756353',['square-arrow-out-down-right']='rbxassetid://89971003001390',['square-arrow-out-up-left']='rbxassetid://103759986579087',['square-arrow-out-up-right']='rbxassetid://91221896066807',['square-arrow-right']='rbxassetid://113920471701361',['square-arrow-up-left']='rbxassetid://112424670290693',['square-arrow-up-right']='rbxassetid://76602291406940',['square-arrow-up']='rbxassetid://106998604646718',['square-asterisk']='rbxassetid://89186832353625',['square-bottom-dashed-scissors']='rbxassetid://79076980104803',['square-chart-gantt']='rbxassetid://104034017316411',['square-check-big']='rbxassetid://115320390907184',['square-check']='rbxassetid://134682053539509',['square-chevron-down']='rbxassetid://91032307924592',['square-chevron-left']='rbxassetid://73143404829510',['square-chevron-right']='rbxassetid://90612077729930',['square-chevron-up']='rbxassetid://85565910197337',['square-code']='rbxassetid://81604576616881',['square-dashed-bottom-code']='rbxassetid://100354801563230',['square-dashed-bottom']='rbxassetid://101102319625624',['square-dashed-kanban']='rbxassetid://90388067649847',['square-dashed-mouse-pointer']='rbxassetid://121016142178467',['square-dashed-top-solid']='rbxassetid://117157577548540',['square-dashed']='rbxassetid://136905537847606',['square-divide']='rbxassetid://99894657101970',['square-dot']='rbxassetid://116613421354866',['square-equal']='rbxassetid://110283363706707',['square-function']='rbxassetid://86075219551088',['square-kanban']='rbxassetid://114537101260131',['square-library']='rbxassetid://73810931222081',['square-m']='rbxassetid://117662700410577',['square-menu']='rbxassetid://104067089444415',['square-minus']='rbxassetid://116764432015770',['square-mouse-pointer']='rbxassetid://76141850603920',['square-parking-off']='rbxassetid://100857293535141',['square-parking']='rbxassetid://133116656122387',['square-pause']='rbxassetid://86608552787615',['square-pen']='rbxassetid://120239476110475',['square-percent']='rbxassetid://87111930314567',['square-pi']='rbxassetid://75383328781618',['square-pilcrow']='rbxassetid://131854284699367',['square-play']='rbxassetid://108186325238481',['square-plus']='rbxassetid://114713264461873',['square-power']='rbxassetid://129240437805187',['square-radical']='rbxassetid://132645931868292',['square-round-corner']='rbxassetid://104592745113567',['square-scissors']='rbxassetid://110601255612411',['square-sigma']='rbxassetid://113231244246816',['square-slash']='rbxassetid://105477013908757',['square-split-horizontal']='rbxassetid://76095370148660',['square-split-vertical']='rbxassetid://88589192032058',['square-square']='rbxassetid://136555087357875',['square-stack']='rbxassetid://100463396619394',['square-star']='rbxassetid://94506958703720',['square-stop']='rbxassetid://80018708472943',['square-terminal']='rbxassetid://83969264476798',['square-user-round']='rbxassetid://86484997229302',['square-user']='rbxassetid://70771214183445',['square-x']='rbxassetid://125136183850190',square='rbxassetid://86304921356806',['squares-exclude']='rbxassetid://102345385822324',['squares-intersect']='rbxassetid://120869602570119',['squares-subtract']='rbxassetid://131484650948795',['squares-unite']='rbxassetid://96673080107843',['squircle-dashed']='rbxassetid://129936702532522',squircle='rbxassetid://82426632573807',squirrel='rbxassetid://112864252085343',stamp='rbxassetid://92370779813368',['star-half']='rbxassetid://117449275562979',['star-off']='rbxassetid://75742832732503',star='rbxassetid://136141469398409',['step-back']='rbxassetid://108672750005121',['step-forward']='rbxassetid://126131872136145',stethoscope='rbxassetid://122331031702148',sticker='rbxassetid://79938203791608',['sticky-note']='rbxassetid://111894074643919',store='rbxassetid://90338129673705',['stretch-horizontal']='rbxassetid://87665042192343',['stretch-vertical']='rbxassetid://95265463417122',strikethrough='rbxassetid://103417324549613',subscript='rbxassetid://74553514785183',['sun-dim']='rbxassetid://129141645592715',['sun-medium']='rbxassetid://130278807964710',['sun-moon']='rbxassetid://75752898854559',['sun-snow']='rbxassetid://112791898014579',sun='rbxassetid://110150589884127',sunrise='rbxassetid://134705665494098',sunset='rbxassetid://75904872203588',superscript='rbxassetid://96887696590118',['swatch-book']='rbxassetid://126786244872453',['swiss-franc']='rbxassetid://113497920041625',['switch-camera']='rbxassetid://76841154349737',sword='rbxassetid://124448418211665',swords='rbxassetid://81872698913435',syringe='rbxassetid://123891270479254',['table-2']='rbxassetid://95751552281545',['table-cells-merge']='rbxassetid://95363715175258',['table-cells-split']='rbxassetid://114799086088649',['table-columns-split']='rbxassetid://111011625447949',['table-of-contents']='rbxassetid://135044763275414',['table-properties']='rbxassetid://125062886015372',['table-rows-split']='rbxassetid://96443733673997',table='rbxassetid://109109148250737',['tablet-smartphone']='rbxassetid://133680859813404',tablet='rbxassetid://128403991264386',tablets='rbxassetid://80835787970735',tag='rbxassetid://129104970103940',tags='rbxassetid://107179263080798',['tally-1']='rbxassetid://115301298241643',['tally-2']='rbxassetid://110363186864027',['tally-3']='rbxassetid://97655344572540',['tally-4']='rbxassetid://102633494371890',['tally-5']='rbxassetid://88031817475886',tangent='rbxassetid://123263132981724',target='rbxassetid://87563802520297',telescope='rbxassetid://91755049143647',['tent-tree']='rbxassetid://76698322463977',tent='rbxassetid://109779587826330',terminal='rbxassetid://106783148545356',['test-tube-diagonal']='rbxassetid://75662704378840',['test-tube']='rbxassetid://98801015650164',['test-tubes']='rbxassetid://92555361447433',['text-align-center']='rbxassetid://84051028246390',['text-align-end']='rbxassetid://130041738343555',['text-align-justify']='rbxassetid://80279880143030',['text-align-start']='rbxassetid://134489585487649',['text-cursor-input']='rbxassetid://107551944047171',['text-cursor']='rbxassetid://115984654447300',['text-initial']='rbxassetid://129458097472087',['text-quote']='rbxassetid://139278366448736',['text-search']='rbxassetid://92345384671606',['text-select']='rbxassetid://117087320884956',['text-wrap']='rbxassetid://114804318314018',theater='rbxassetid://108558145549163',['thermometer-snowflake']='rbxassetid://121876188028425',['thermometer-sun']='rbxassetid://106693240074310',thermometer='rbxassetid://106546011492311',['thumbs-down']='rbxassetid://87794009914015',['thumbs-up']='rbxassetid://111137070767020',['ticket-check']='rbxassetid://105428777212507',['ticket-minus']='rbxassetid://78966299769328',['ticket-percent']='rbxassetid://80834774406405',['ticket-plus']='rbxassetid://110086734392189',['ticket-slash']='rbxassetid://89045681172265',['ticket-x']='rbxassetid://88674114109926',ticket='rbxassetid://126527071492145',['tickets-plane']='rbxassetid://100367018248695',tickets='rbxassetid://135268612687833',['timer-off']='rbxassetid://110916370767271',['timer-reset']='rbxassetid://110052125369932',timer='rbxassetid://85473888890506',['toggle-left']='rbxassetid://85887872573050',['toggle-right']='rbxassetid://90411952142550',toilet='rbxassetid://80930782432931',['tool-case']='rbxassetid://87533537832522',tornado='rbxassetid://88358291515768',torus='rbxassetid://70855707283051',['touchpad-off']='rbxassetid://78784008075456',touchpad='rbxassetid://74882354908014',['tower-control']='rbxassetid://95937619060532',['toy-brick']='rbxassetid://86293483924633',tractor='rbxassetid://103376704722051',['traffic-cone']='rbxassetid://74110220470369',['train-front-tunnel']='rbxassetid://105194827005114',['train-front']='rbxassetid://125237934215370',['train-track']='rbxassetid://77451032453723',['tram-front']='rbxassetid://93315182364998',transgender='rbxassetid://135530817673639',['trash-2']='rbxassetid://109843431391323',trash='rbxassetid://106723740584310',['tree-deciduous']='rbxassetid://123124389219004',['tree-palm']='rbxassetid://103846705893963',['tree-pine']='rbxassetid://124662547202594',trees='rbxassetid://121203841375919',trello='rbxassetid://130987241149527',['trending-down']='rbxassetid://139309232226438',['trending-up-down']='rbxassetid://85083293981691',['trending-up']='rbxassetid://81819858538839',['triangle-alert']='rbxassetid://125920361880643',['triangle-dashed']='rbxassetid://124324079103935',['triangle-right']='rbxassetid://116930791412791',triangle='rbxassetid://126330486745540',trophy='rbxassetid://131545003268773',['truck-electric']='rbxassetid://111873446387359',truck='rbxassetid://86662707764771',['turkish-lira']='rbxassetid://114589876174070',turntable='rbxassetid://129870346487856',turtle='rbxassetid://118295081560334',['tv-minimal-play']='rbxassetid://99201833426972',['tv-minimal']='rbxassetid://100382201729427',tv='rbxassetid://135687724791776',twitch='rbxassetid://71383308134888',twitter='rbxassetid://88791703276842',['type-outline']='rbxassetid://80108627791690',type='rbxassetid://133543553793564',['umbrella-off']='rbxassetid://72395143739955',umbrella='rbxassetid://127502210274589',underline='rbxassetid://123709229216544',['undo-2']='rbxassetid://113885292059932',['undo-dot']='rbxassetid://132055277744844',undo='rbxassetid://111258459077271',['unfold-horizontal']='rbxassetid://117128358526398',['unfold-vertical']='rbxassetid://116593025265499',ungroup='rbxassetid://106674800451003',university='rbxassetid://84652528263642',['unlink-2']='rbxassetid://128131898892572',unlink='rbxassetid://139835795227752',unplug='rbxassetid://90171381619874',upload='rbxassetid://138212042425501',usb='rbxassetid://117230058949613',['user-check']='rbxassetid://81775205032725',['user-cog']='rbxassetid://92795491530865',['user-lock']='rbxassetid://78892639693821',['user-minus']='rbxassetid://126976941957511',['user-pen']='rbxassetid://87445472574836',['user-plus']='rbxassetid://118514469915884',['user-round-check']='rbxassetid://118794737621941',['user-round-cog']='rbxassetid://78239503290053',['user-round-minus']='rbxassetid://98944176636447',['user-round-pen']='rbxassetid://108155244324878',['user-round-plus']='rbxassetid://113301899567470',['user-round-search']='rbxassetid://71565774381870',['user-round-x']='rbxassetid://122367980560930',['user-round']='rbxassetid://136485052187963',['user-search']='rbxassetid://101335649828115',['user-star']='rbxassetid://98777846316000',['user-x']='rbxassetid://139748155894754',user='rbxassetid://81589895647169',['users-round']='rbxassetid://103005444008339',users='rbxassetid://115398113982385',['utensils-crossed']='rbxassetid://109520762270383',utensils='rbxassetid://139952569804235',['utility-pole']='rbxassetid://101965541238242',variable='rbxassetid://104743088438151',vault='rbxassetid://108049164599845',['vector-square']='rbxassetid://86713728565344',vegan='rbxassetid://119489190688082',['venetian-mask']='rbxassetid://102636443033920',['venus-and-mars']='rbxassetid://120227752103771',venus='rbxassetid://82891342220859',['vibrate-off']='rbxassetid://113446447326246',vibrate='rbxassetid://108330910738733',['video-off']='rbxassetid://132239189859305',video='rbxassetid://107587444636945',videotape='rbxassetid://114816894323398',view='rbxassetid://118717253976805',voicemail='rbxassetid://134313454010227',volleyball='rbxassetid://83889351124153',['volume-1']='rbxassetid://98514588731639',['volume-2']='rbxassetid://89344380902620',['volume-off']='rbxassetid://103047478058767',['volume-x']='rbxassetid://139252359189540',volume='rbxassetid://103236289817396',vote='rbxassetid://89409762851246',['wallet-cards']='rbxassetid://129728715308337',['wallet-minimal']='rbxassetid://137800448816116',wallet='rbxassetid://132331555762628',wallpaper='rbxassetid://74682121235494',['wand-sparkles']='rbxassetid://82546429942392',wand='rbxassetid://114580617777835',warehouse='rbxassetid://78388887451080',['washing-machine']='rbxassetid://104194127573858',watch='rbxassetid://130544621618405',['waves-ladder']='rbxassetid://101808619355514',waves='rbxassetid://96340135183647',waypoints='rbxassetid://102450133666017',webcam='rbxassetid://104148487911129',['webhook-off']='rbxassetid://96370548093471',webhook='rbxassetid://112812457747322',weight='rbxassetid://103860559844854',['wheat-off']='rbxassetid://133294844612307',wheat='rbxassetid://85261952080359',['whole-word']='rbxassetid://90111083954485',['wifi-cog']='rbxassetid://110500263326209',['wifi-high']='rbxassetid://81954601342139',['wifi-low']='rbxassetid://138217335635913',['wifi-off']='rbxassetid://74113634330106',['wifi-pen']='rbxassetid://91290205064712',['wifi-sync']='rbxassetid://84043971055177',['wifi-zero']='rbxassetid://124286465246123',wifi='rbxassetid://104669375183960',['wind-arrow-down']='rbxassetid://127753987414870',wind='rbxassetid://114551690399915',['wine-off']='rbxassetid://108294164302317',wine='rbxassetid://115743721332829',workflow='rbxassetid://99186544029189',worm='rbxassetid://115752311548091',wrench='rbxassetid://112148279212860',x='rbxassetid://110786993356448',youtube='rbxassetid://123663668456341',['zap-off']='rbxassetid://81385483183652',zap='rbxassetid://130551565616516',['zoom-in']='rbxassetid://127956924984803',['zoom-out']='rbxassetid://108334162607319',balloon='rbxassetid://97489111621526',['beef-off']='rbxassetid://99869959725200',['book-search']='rbxassetid://132585409504950',calendars='rbxassetid://130944763042289',['cannabis-off']='rbxassetid://101938500363812',['cctv-off']='rbxassetid://75925370187295',cigarette='rbxassetid://137149549886852',['circle-pile']='rbxassetid://116353155251541',['cloud-backup']='rbxassetid://111649579696132',['cloud-sync']='rbxassetid://79393911188593',['database-search']='rbxassetid://92017137080138',ellipse='rbxassetid://71559658267482',['fingerprint-pattern']='rbxassetid://80934710831288',['fishing-hook']='rbxassetid://121038780855899',['fishing-rod']='rbxassetid://71754848048049',form='rbxassetid://72999643971000',['git-merge-conflict']='rbxassetid://85677801675703',['globe-off']='rbxassetid://77775243585824',['globe-x']='rbxassetid://109268097029296',hd='rbxassetid://71682790698278',image='rbxassetid://112751259236831',['layers-plus']='rbxassetid://77587765623057',['lens-concave']='rbxassetid://94819631937027',['lens-convex']='rbxassetid://74736504195474',['line-dot-right-horizontal']='rbxassetid://104718593155221',['line-style']='rbxassetid://90176717785772',['map-pin-search']='rbxassetid://89065012915078',['message-circle-check']='rbxassetid://132772297689418',['message-square-check']='rbxassetid://125789987055668',metronome='rbxassetid://101991829345965',['mirror-rectangular']='rbxassetid://109046769760336',['mirror-round']='rbxassetid://121534049429097',['mouse-left']='rbxassetid://99144293708743',['mouse-right']='rbxassetid://88331710212594',['printer-x']='rbxassetid://103002721801548',['radio-off']='rbxassetid://80359258046586',road='rbxassetid://120251329173530',scooter='rbxassetid://100035452787934',['search-alert']='rbxassetid://127597984617505',['shelving-unit']='rbxassetid://80116568514793',['shield-cog-corner']='rbxassetid://111694066132698',['shield-cog']='rbxassetid://129235695057857',['sport-shoe']='rbxassetid://120495992692630',['square-arrow-right-enter']='rbxassetid://138867831495334',['square-arrow-right-exit']='rbxassetid://133688575845430',['square-centerline-dashed-horizontal']='rbxassetid://77780104374341',['square-centerline-dashed-vertical']='rbxassetid://107878435803525',stone='rbxassetid://135161057497830',toolbox='rbxassetid://85341033903792',['towel-rack']='rbxassetid://125223915620991',['user-key']='rbxassetid://105403041782190',['user-round-key']='rbxassetid://124547549008939',van='rbxassetid://122066377022942',['waves-arrow-down']='rbxassetid://129215220911792',['waves-arrow-up']='rbxassetid://102314705716217',['weight-tilde']='rbxassetid://112081212176951',['x-line-top']='rbxassetid://140592656289509',['zodiac-aquarius']='rbxassetid://74560047770362',['zodiac-aries']='rbxassetid://73255859670234',['zodiac-cancer']='rbxassetid://131985162532947',['zodiac-capricorn']='rbxassetid://97859568140652',['zodiac-gemini']='rbxassetid://80997588122992',['zodiac-leo']='rbxassetid://75509406718106',['zodiac-libra']='rbxassetid://113222735060218',['zodiac-ophiuchus']='rbxassetid://129180108892480',['zodiac-pisces']='rbxassetid://95845819440327',['zodiac-sagittarius']='rbxassetid://82651026742181',['zodiac-scorpio']='rbxassetid://113640924054631',['zodiac-taurus']='rbxassetid://123053219704400',['zodiac-virgo']='rbxassetid://99462994613661'}

local ICON_ALIASES = {
    ["home"] = "house",
    ["gear"] = "settings",
    ["cog"] = "settings",
    ["location"] = "map-pin",
    ["teleport"] = "map-pin",
    ["player"] = "user",
    ["players"] = "users",
    ["money"] = "banknote",
    ["coin"] = "coins",
    ["exit"] = "log-out",
    ["quit"] = "x",
    ["close"] = "x",
}

local function ResolveIcon(icon)
    if not icon or icon == "" then return nil end
    if type(icon) == "number" then return "rbxassetid://" .. tostring(icon) end
    if type(icon) ~= "string" then return nil end
    
    if icon:match("^https?://") then
        local ok, customAsset = pcall(function()
            local cleanName = icon:gsub("[^%w%.%-_]", "_")
            if #cleanName > 64 then cleanName = string.sub(cleanName, -60) end
            local path = "LimboHUB/assets/." .. cleanName
            if makefolder and isfolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
            if makefolder and isfolder and not isfolder("LimboHUB/assets") then makefolder("LimboHUB/assets") end
            if isfile and not isfile(path) then
                local req = (syn and syn.request) or (http and http.request) or request or http_request
                local body = (game.HttpGet and game:HttpGet(icon)) or (req and req({Url = icon, Method = "GET"}).Body)
                if body and writefile then writefile(path, body) end
            end
            if getcustomasset and isfile and isfile(path) then
                return getcustomasset(path)
            end
            return nil
        end)
        if ok and customAsset then return customAsset end
    end

    if icon:match("^rbxasset") or icon:match("^rbxthumb") then
        return icon
    end

    local clean = icon
    if clean:sub(1, 7) == "lucide:" then
        clean = clean:sub(8)
    end

    local lower = clean:lower()
    if ICON_ALIASES[lower] then
        lower = ICON_ALIASES[lower]
    end

    if LucideIcons[clean] then
        return LucideIcons[clean]
    end
    if LucideIcons[lower] then
        return LucideIcons[lower]
    end

    return icon
end

local ConfigSystem = {
    CurrentConfig = nil,
    Configs = {},
    ThemeColors = {
        ["Limbo"] = Color3.fromHex("#FF00E0"),
        ["Darker"] = Color3.fromHex("#FF00E0"),
        ["Magenta"] = Color3.fromHex("#FF00E0"),
        ["Purple"] = Color3.fromHex("#FF00E0"),
    },
    CurrentTheme = "Limbo",
    ThemeElements = {},
    ToggleElements = {},
    SliderElements = {},
    DropdownElements = {},
    TabElements = {},
    AllElements = {},
    DropdownOptionFrames = {}
}

function ConfigSystem:SetTheme(themeName)
    if self.ThemeColors[themeName] then
        self.CurrentTheme = themeName
        local newColor = self.ThemeColors[themeName]
        self:UpdateAllThemeElements(newColor)
        return true, newColor
    end
    return false, nil
end

function ConfigSystem:UpdateAllThemeElements(newColor)
    for _, toggle in pairs(self.ToggleElements) do
        if toggle and toggle:IsA("Frame") then
            local featureFrame = toggle:FindFirstChild("FeatureFrame")
            local toggleCircle = toggle:FindFirstChild("ToggleCircle")
            local frameStroke = featureFrame and featureFrame:FindFirstChild("UIStroke")
            local toggleTitle = toggle:FindFirstChild("ToggleTitle")

            if toggleCircle then
                local isOn = toggleCircle.Position == UDim2.new(0, 15, 0, 0)
                if isOn then
                    toggleCircle.BackgroundColor3 = newColor
                    if frameStroke then
                        frameStroke.Color = newColor
                    end
                    if featureFrame then
                        featureFrame.BackgroundColor3 = newColor
                    end
                    if toggleTitle then
                        toggleTitle.TextColor3 = newColor
                    end
                end
            end
        end
    end

    for _, slider in pairs(self.SliderElements) do
        if slider and slider:IsA("Frame") then
            local sliderFill = slider:FindFirstChild("SliderFill")

            if sliderFill then
                sliderFill.BackgroundColor3 = newColor
            end
        end
    end

    for _, dropdown in pairs(self.DropdownElements) do
        if dropdown and dropdown:IsA("Frame") then
            local dropdownList = dropdown:FindFirstChild("DropdownList")
            if dropdownList then
                local listScroll = dropdownList:FindFirstChild("ListScroll")
                if listScroll then
                    for _, option in listScroll:GetChildren() do
                        if option:IsA("Frame") and option.Name == "Option" then
                            local chooseFrame = option:FindFirstChild("ChooseFrame")
                            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                            local optionText = option:FindFirstChild("OptionText")

                            if chooseFrame then
                                chooseFrame.BackgroundColor3 = newColor
                            end
                            if chooseStroke then
                                chooseStroke.Color = newColor
                            end
                            if optionText and optionText.TextColor3 ~= Color3.fromRGB(230, 230, 230) then
                                optionText.TextColor3 = newColor
                            end
                        end
                    end
                end
            end
        end
    end

    for _, optionData in pairs(self.DropdownOptionFrames) do
        if optionData.Frame and optionData.Frame.Parent then
            local chooseFrame = optionData.Frame:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
            local optionText = optionData.Frame:FindFirstChild("OptionText")

            if optionData.IsSelected then
                if chooseFrame then
                    chooseFrame.BackgroundColor3 = newColor
                end
                if chooseStroke then
                    chooseStroke.Color = newColor
                end
                if optionText then
                    optionText.TextColor3 = newColor
                end
            end
        end
    end

    for _, tab in pairs(self.TabElements) do
        if tab and tab:IsA("Frame") then
            local chooseFrame = tab:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")

            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
            end
            if chooseStroke then
                chooseStroke.Color = newColor
            end
        end
    end

    for _, element in pairs(self.ThemeElements) do
        if element and element:IsA("Frame") and element:FindFirstChild("ChooseFrame") then
            local chooseFrame = element.ChooseFrame
            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
                local stroke = chooseFrame:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = newColor
                end
            end
        elseif type(element) == "table" and element.Update then
            element.Update(newColor)
        end
    end

    return newColor
end

function ConfigSystem:EnsureFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

function ConfigSystem:SaveConfig(name, data)
    self:EnsureFolder()

    local success, encoded =
        pcall(
        function()
            return HttpService:JSONEncode(data or {})
        end
    )

    if success then
        writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
        self.CurrentConfig = name

        return {
            Title = "Config",
            Description = "Saved",
            Content = "Config '" .. name .. "' saved successfully!",
            Color = self.ThemeColors[self.CurrentTheme],
            Delay = 3
        }
    else
        return {
            Title = "Config",
            Description = "Error",
            Content = "Failed to save config: " .. tostring(encoded),
            Color = Color3.fromRGB(150, 150, 170),
            Delay = 3
        }
    end
end

function ConfigSystem:LoadConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"

    if isfile(filePath) then
        local success, content =
            pcall(
            function()
                return readfile(filePath)
            end
        )

        if success then
            local decodeSuccess, decoded =
                pcall(
                function()
                    return HttpService:JSONDecode(content)
                end
            )

            if decodeSuccess and decoded then
                self.CurrentConfig = name
                -- support both flat format and legacy {Data=...} format
                local configData = decoded.Data or decoded
                return {
                    Title = "Config",
                    Description = "Loaded",
                    Content = "Config '" .. name .. "' loaded successfully!",
                    Color = self.ThemeColors[self.CurrentTheme],
                    Delay = 3
                }, configData
            end
        end
    end

    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found or corrupted!",
        Color = Color3.fromRGB(150, 150, 170),
        Delay = 3
    }, nil
end

function ConfigSystem:DeleteConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"

    if isfile(filePath) then
        local success =
            pcall(
            function()
                delfile(filePath)
            end
        )

        if success then
            if self.CurrentConfig == name then
                self.CurrentConfig = nil
            end

            return {
                Title = "Config",
                Description = "Deleted",
                Content = "Config '" .. name .. "' deleted successfully!",
                Color = self.ThemeColors[self.CurrentTheme],
                Delay = 3
            }
        end
    end

    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found!",
        Color = Color3.fromRGB(150, 150, 170),
        Delay = 3
    }
end

function ConfigSystem:GetConfigList()
    self:EnsureFolder()
    local configs = {}

    local success, files =
        pcall(
        function()
            return listfiles(ConfigFolder)
        end
    )

    if success and files then
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/\\]+)%.json$")
            if fileName then
                table.insert(configs, fileName)
            end
        end
    end

    return configs
end

local function MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Notification"
    NotifyConfig.Description = NotifyConfig.Description or ""
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromHex("#FF00E0")
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5

    local NotifyFunction = {}

    spawn(
        function()
            if not CoreGui:FindFirstChild("NotifyGui") then
                local NotifyGui = Instance.new("ScreenGui")
                NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                NotifyGui.Name = "NotifyGui"
                NotifyGui.Parent = (gethui and gethui()) or CoreGui
            end

            if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
                local NotifyLayout = Instance.new("Frame")
                NotifyLayout.AnchorPoint = Vector2.new(1, 1)
                NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                NotifyLayout.BackgroundTransparency = 0.999
                NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
                NotifyLayout.BorderSizePixel = 0
                NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
                NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
                NotifyLayout.Name = "NotifyLayout"
                NotifyLayout.Parent = CoreGui.NotifyGui

                local Count = 0
                CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(
                    function()
                        Count = 0
                        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                            TweenService:Create(
                                v,
                                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                                {Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))}
                            ):Play()
                            Count = Count + 1
                        end
                    end
                )
            end

            local NotifyPosHeigh = 0
            for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
            end

            local NotifyFrame = Instance.new("Frame")
            local NotifyFrameReal = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local DropShadowHolder = Instance.new("Frame")
            local DropShadow = Instance.new("ImageLabel")
            local Top = Instance.new("Frame")
            local TextLabel = Instance.new("TextLabel")
            local UIStroke = Instance.new("UIStroke")
            local UICorner1 = Instance.new("UICorner")
            local TextLabel1 = Instance.new("TextLabel")
            local UIStroke1 = Instance.new("UIStroke")
            local Close = Instance.new("TextButton")
            local ImageLabel = Instance.new("ImageLabel")
            local TextLabel2 = Instance.new("TextLabel")

            NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrame.BorderSizePixel = 0
            NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
            NotifyFrame.Name = "NotifyFrame"
            NotifyFrame.BackgroundTransparency = 1
            NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
            NotifyFrame.AnchorPoint = Vector2.new(0, 1)
            NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

            NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyFrameReal.BorderSizePixel = 0
            NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
            NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
            NotifyFrameReal.Name = "NotifyFrameReal"
            NotifyFrameReal.Parent = NotifyFrame

            UICorner.Parent = NotifyFrameReal

            -- Accent pill kiri
            local AccentPill = Instance.new("Frame")
            AccentPill.BackgroundColor3 = NotifyConfig.Color
            AccentPill.Size = UDim2.new(0, 3, 1, 0)
            AccentPill.Position = UDim2.new(0, 0, 0, 0)
            AccentPill.BorderSizePixel = 0
            AccentPill.ZIndex = 4
            AccentPill.Parent = NotifyFrameReal
            UICorner.CornerRadius = UDim.new(0, 8)

            DropShadowHolder.BackgroundTransparency = 1
            DropShadowHolder.BorderSizePixel = 0
            DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
            DropShadowHolder.ZIndex = 0
            DropShadowHolder.Name = "DropShadowHolder"
            DropShadowHolder.Parent = NotifyFrameReal

            DropShadow.Image = "rbxassetid://6015897843"
            DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            DropShadow.ImageTransparency = 0.5
            DropShadow.ScaleType = Enum.ScaleType.Slice
            DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            DropShadow.BackgroundTransparency = 1
            DropShadow.BorderSizePixel = 0
            DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            DropShadow.Size = UDim2.new(1, 47, 1, 47)
            DropShadow.ZIndex = 0
            DropShadow.Name = "DropShadow"
            DropShadow.Parent = DropShadowHolder

            Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Top.BackgroundTransparency = 0.999
            Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Top.BorderSizePixel = 0
            Top.Size = UDim2.new(1, 0, 0, 36)
            Top.Name = "Top"
            Top.Parent = NotifyFrameReal

            Top.Size = UDim2.new(1, -30, 0, 26)
            Top.Position = UDim2.new(0, 10, 0, 8)

            local TopLayout = Instance.new("UIListLayout")
            TopLayout.FillDirection = Enum.FillDirection.Horizontal
            TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            TopLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TopLayout.Padding = UDim.new(0, 6)
            TopLayout.Parent = Top

            local notifyIconUrl = ResolveIcon(NotifyConfig.Icon or "rbxthumb://type=Asset&id=93432513909214&w=420&h=420")
            if notifyIconUrl then
                local NIcon = Instance.new("ImageLabel")
                NIcon.Image = notifyIconUrl
                NIcon.BackgroundTransparency = 1
                NIcon.Size = UDim2.new(0, 16, 0, 16)
                NIcon.LayoutOrder = 1
                NIcon.Parent = Top
            end

            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = NotifyConfig.Title
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.BackgroundTransparency = 1
            TextLabel.BorderSizePixel = 0
            TextLabel.AutomaticSize = Enum.AutomaticSize.XY
            TextLabel.LayoutOrder = 2
            TextLabel.Parent = Top

            if NotifyConfig.Subtitle and NotifyConfig.Subtitle ~= "" then
                local SubLabel = Instance.new("TextLabel")
                SubLabel.Font = Enum.Font.Gotham
                SubLabel.Text = "• " .. tostring(NotifyConfig.Subtitle)
                SubLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
                SubLabel.TextSize = 11
                SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                SubLabel.BackgroundTransparency = 1
                SubLabel.BorderSizePixel = 0
                SubLabel.AutomaticSize = Enum.AutomaticSize.XY
                SubLabel.LayoutOrder = 3
                SubLabel.Parent = Top
            end

            if NotifyConfig.Description and NotifyConfig.Description ~= "" and NotifyConfig.Description ~= NotifyConfig.Title then
                TextLabel1.Font = Enum.Font.GothamBold
                TextLabel1.Text = NotifyConfig.Description
                TextLabel1.TextColor3 = NotifyConfig.Color
                TextLabel1.TextSize = 12
                TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel1.BackgroundTransparency = 1
                TextLabel1.BorderSizePixel = 0
                TextLabel1.AutomaticSize = Enum.AutomaticSize.XY
                TextLabel1.LayoutOrder = 4
                TextLabel1.Parent = Top
            else
                TextLabel1.Visible = false
            end

            Close.Font = Enum.Font.SourceSans
            Close.Text = ""
            Close.TextColor3 = Color3.fromRGB(0, 0, 0)
            Close.TextSize = 14
            Close.AnchorPoint = Vector2.new(1, 0.5)
            Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Close.BackgroundTransparency = 0.999
            Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Close.BorderSizePixel = 0
            Close.Position = UDim2.new(1, -6, 0, 20)
            Close.Size = UDim2.new(0, 22, 0, 22)
            Close.Name = "Close"
            Close.Parent = NotifyFrameReal

            ImageLabel.Image = "rbxassetid://9886659671"
            ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel.BackgroundTransparency = 0.999
            ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ImageLabel.BorderSizePixel = 0
            ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            ImageLabel.Size = UDim2.new(1, -8, 1, -8)
            ImageLabel.Parent = Close

            TextLabel2.Font = Enum.Font.Gotham
            TextLabel2.Text = NotifyConfig.Content
            TextLabel2.TextSize = 12
            TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
            TextLabel2.BackgroundTransparency = 1
            TextLabel2.TextColor3 = Color3.fromRGB(220, 220, 230)
            TextLabel2.TextTransparency = 0.15
            TextLabel2.BorderSizePixel = 0
            TextLabel2.Position = UDim2.new(0, 12, 0, 36)
            TextLabel2.Size = UDim2.new(1, -24, 0, 0)
            TextLabel2.AutomaticSize = Enum.AutomaticSize.Y
            TextLabel2.TextWrapped = true
            TextLabel2.Parent = NotifyFrameReal

            local contentHeight = TextService:GetTextSize(
                NotifyConfig.Content or "",
                12,
                Enum.Font.Gotham,
                Vector2.new(280, math.huge)
            ).Y
            NotifyFrame.Size = UDim2.new(1, 0, 0, math.max(62, contentHeight + 46))

            local waitbruh = false
            function NotifyFunction:Close()
                if waitbruh then
                    return false
                end
                waitbruh = true
                TweenService:Create(
                    NotifyFrameReal,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    {Position = UDim2.new(0, 400, 0, 0)}
                ):Play()
                task.wait(tonumber(NotifyConfig.Time) / 1.2)
                NotifyFrame:Destroy()
            end

            Close.Activated:Connect(
                function()
                    NotifyFunction:Close()
                end
            )

            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}
            ):Play()
            task.wait(tonumber(NotifyConfig.Delay))
            NotifyFunction:Close()
        end
    )

    return NotifyFunction
end


-- Close confirmation modal (module-level: avoids CreateWindow local limit)
local function setupCloseModal(closeBtn, main, screenGui)
    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.ZIndex = 50
    overlay.Active = true
    overlay.Visible = false
    overlay.Parent = main
    local dialog = Instance.new("Frame")
    dialog.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    dialog.BorderSizePixel = 0
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.Size = UDim2.new(0, 300, 0, 155)
    dialog.ZIndex = 51
    dialog.Parent = overlay
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0, 10)
    dc.Parent = dialog
    local ds = Instance.new("UIStroke")
    ds.Color = Color3.fromRGB(150, 150, 170)
    ds.Thickness = 1.5
    ds.Parent = dialog
    local dt = Instance.new("TextLabel")
    dt.Font = Enum.Font.GothamBold
    dt.Text = "Close Window"
    dt.TextColor3 = Color3.fromRGB(255, 255, 255)
    dt.TextSize = 24
    dt.BackgroundTransparency = 1
    dt.Size = UDim2.new(1, 0, 0, 36)
    dt.Position = UDim2.new(0, 0, 0, 10)
    dt.TextXAlignment = Enum.TextXAlignment.Center
    dt.ZIndex = 52
    dt.Parent = dialog
    local body = Instance.new("TextLabel")
    body.Font = Enum.Font.Gotham
    body.Text = "Are you sure you want to close this window?"
    body.TextColor3 = Color3.fromRGB(150, 150, 170)
    body.TextSize = 15
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, -20, 0, 28)
    body.Position = UDim2.new(0, 10, 0, 52)
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.TextWrapped = true
    body.ZIndex = 52
    body.Parent = dialog
    local sub = Instance.new("TextLabel")
    sub.Font = Enum.Font.Gotham
    sub.Text = "You will not be able to open it again"
    sub.TextColor3 = Color3.fromRGB(150, 150, 170)
    sub.TextSize = 15
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, -20, 0, 18)
    sub.Position = UDim2.new(0, 10, 0, 82)
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.ZIndex = 52
    sub.Parent = dialog
    local btnYes = Instance.new("TextButton")
    btnYes.Font = Enum.Font.GothamBold
    btnYes.Text = "Yes"
    btnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnYes.TextSize = 14
    btnYes.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btnYes.BorderSizePixel = 0
    btnYes.Size = UDim2.new(0, 120, 0, 32)
    btnYes.Position = UDim2.new(0, 16, 1, -44)
    btnYes.ZIndex = 52
    btnYes.AutoButtonColor = false
    btnYes.Parent = dialog
    local yc = Instance.new("UICorner")
    yc.CornerRadius = UDim.new(0, 6)
    yc.Parent = btnYes
    local btnCancel = Instance.new("TextButton")
    btnCancel.Font = Enum.Font.GothamBold
    btnCancel.Text = "Cancel"
    btnCancel.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCancel.TextSize = 14
    btnCancel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btnCancel.BorderSizePixel = 0
    btnCancel.Size = UDim2.new(0, 120, 0, 32)
    btnCancel.Position = UDim2.new(1, -136, 1, -44)
    btnCancel.ZIndex = 52
    btnCancel.AutoButtonColor = false
    btnCancel.Parent = dialog
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = btnCancel
    btnCancel.Activated:Connect(function() overlay.Visible = false end)
    btnYes.Activated:Connect(function()
        for _, fn in pairs(Limbo._resetCallbacks) do
            pcall(fn)
        end
        task.wait(0.1)
        screenGui:Destroy()
    end)
    closeBtn.Activated:Connect(function()
        CircleClick(closeBtn, Mouse.X, Mouse.Y)
        overlay.Visible = true
    end)
end

function Limbo:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Limbo UI"
    local Theme = config.Theme or "Limbo"
    local Size = config.Size or UDim2.fromOffset(470, 270)
    local Center = config.Center ~= false
    local Draggable = config.Draggable ~= false
    local Resizable = config.Resizable or config.Resize or false
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    if config.ConfigFolder then ConfigFolder = config.ConfigFolder end
    local MinimizeButton = config.MinimizeButton or false
    local MinimizeButtonImage = config.MinimizeButton_Image or "rbxassetid://16932740082"
    local Badges = config.Badges or {}
    local Icon = ResolveIcon(config.Icon or "rbxthumb://type=Asset&id=93432513909214&w=420&h=420")
    local TitleImage = config.TitleImage or ""
    local Version = config.Version or ("v" .. LIB_VERSION)
    local ShowExecutor = config.ShowExecutor ~= false
    local ConfigData = config.Config or {}
    local Background = config.Background or config.BackgroundImage or "https://raw.githubusercontent.com/aleyn6969/limbo/refs/heads/main/assets/limbo-watermark-v2.png"
    local BackgroundImageTransparency = config.BackgroundImageTransparency or 0.88
    local Watermark = config.Watermark or ""
    local WatermarkTransparency = config.WatermarkTransparency or 0.94
    local WatermarkSize = config.WatermarkSize or 285

    if ConfigSystem.ThemeColors[Theme] then
        ConfigSystem.CurrentTheme = Theme
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Name = "LimboUI"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = Size
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ScreenGui
    DropShadowHolder.Visible = false

    if Center then
        DropShadowHolder.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
    end

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://8992230677"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.6
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(99, 99, 99, 99)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 100, 1, 100)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    local Main = Instance.new("ImageLabel")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Image = "rbxassetid://89641024074289"
    Main.ImageColor3 = Color3.fromHex("#0B0B0B")
    Main.ImageTransparency = 0
    Main.ScaleType = Enum.ScaleType.Slice
    Main.SliceCenter = Rect.new(460, 460, 460, 460)
    Main.SliceScale = 0.0258
    Main.BackgroundColor3 = Color3.fromHex("#0B0B0B")
    Main.BackgroundTransparency = 1
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -100, 1, -100)
    Main.Name = "Main"
    Main.Parent = DropShadow

    -- No UIStroke on Main squircle image to avoid rectangular black outer corners

    -- Background image (customizable, shown only on selected theme)
    local BgImageId    = config.BackgroundImage       or "rbxthumb://type=Asset&id=93432513909214&w=420&h=420"
    local BgImageTheme = config.BackgroundImage_Theme or "Darker"

    local ImageWrapper = Instance.new("Frame")
    ImageWrapper.Name = "ImageWrapper"
    ImageWrapper.Size = UDim2.new(1, 0, 1, 0)
    ImageWrapper.Position = UDim2.new(0, 0, 0, 0)
    ImageWrapper.BackgroundTransparency = 1
    ImageWrapper.ClipsDescendants = true
    ImageWrapper.ZIndex = 0
    ImageWrapper.Parent = Main

    local ImageWrapperCorner = Instance.new("UICorner")
    ImageWrapperCorner.CornerRadius = UDim.new(0, 8)
    ImageWrapperCorner.Parent = ImageWrapper

    -- Resolve Watermark
    local WatermarkAsset = nil
    if typeof(Watermark) == "string" and Watermark ~= "" then
        if Watermark:match("^rbxasset") then
            WatermarkAsset = Watermark
        elseif Watermark:match("^https?://") then
            pcall(function()
                local assetPath = "LimboHUB/assets/.limbo_watermark.png"
                if makefolder and isfolder and not isfolder("LimboHUB") then makefolder("LimboHUB") end
                if makefolder and isfolder and not isfolder("LimboHUB/assets") then makefolder("LimboHUB/assets") end
                if isfile and not isfile(assetPath) then
                    local reqFn = (syn and syn.request) or (http and http.request) or request or http_request
                    local body = (game.HttpGet and game:HttpGet(Watermark)) or (reqFn and reqFn({Url = Watermark, Method = "GET"}).Body)
                    if body and writefile then writefile(assetPath, body) end
                end
                if getcustomasset and isfile and isfile(assetPath) then
                    WatermarkAsset = getcustomasset(assetPath)
                end
            end)
        end
    end

    if WatermarkAsset then
        local WMLabel = Instance.new("ImageLabel")
        WMLabel.Name = "Watermark"
        WMLabel.Size = UDim2.fromOffset(WatermarkSize, math.floor(WatermarkSize * 496 / 512 + 0.5))
        WMLabel.Position = UDim2.new(0.5, 0, 1, 7)
        WMLabel.AnchorPoint = Vector2.new(0.5, 1)
        WMLabel.BackgroundTransparency = 1
        WMLabel.Image = WatermarkAsset
        WMLabel.ImageTransparency = WatermarkTransparency
        WMLabel.ScaleType = Enum.ScaleType.Fit
        WMLabel.ZIndex = 0
        WMLabel.Parent = ImageWrapper
    end

    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 42)
    Top.Name = "Top"
    Top.Parent = Main

    local DecideFrame = Instance.new("Frame")
    DecideFrame.Name = "HeaderSeparator"
    DecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DecideFrame.Position = UDim2.new(0, 10, 0, 42)
    DecideFrame.Size = UDim2.new(1, -20, 0, 1)
    DecideFrame.BorderSizePixel = 0
    DecideFrame.ZIndex = 2
    DecideFrame.Parent = Main

    local SepCorner = Instance.new("UICorner")
    SepCorner.CornerRadius = UDim.new(1, 0)
    SepCorner.Parent = DecideFrame

    local SepGradient = Instance.new("UIGradient")
    SepGradient.Rotation = 0
    SepGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#2E2E2E")),
        ColorSequenceKeypoint.new(0.28, Color3.fromHex("#4A4A4A")),
        ColorSequenceKeypoint.new(0.55, Color3.fromHex("#5E5E5E")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("#3A3A3A")),
    })
    SepGradient.Parent = DecideFrame

    -- Vertical divider between Sidebar tabs and Content panel (PaneSeparator)
    local PaneSeparator = Instance.new("Frame")
    PaneSeparator.Name = "PaneSeparator"
    PaneSeparator.Size = UDim2.new(0, 1, 1, -54)
    PaneSeparator.Position = UDim2.new(0, 134, 0, 48)
    PaneSeparator.BackgroundColor3 = Color3.fromHex("#242424")
    PaneSeparator.BackgroundTransparency = 0.45
    PaneSeparator.BorderSizePixel = 0
    PaneSeparator.ZIndex = 2
    PaneSeparator.Parent = Main

    local PaneSepGradient = Instance.new("UIGradient")
    PaneSepGradient.Rotation = 90
    PaneSepGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.14, 0.25),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.86, 0.25),
        NumberSequenceKeypoint.new(1, 1)
    })
    PaneSepGradient.Parent = PaneSeparator

    local function createBadge(text, name)
        local Badge = Instance.new("Frame")
        Badge.Name = name or "Badge"
        Badge.AutomaticSize = Enum.AutomaticSize.XY
        Badge.BackgroundColor3 = Color3.fromHex("#2A2A2A")
        Badge.BorderSizePixel = 0

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(1, 0)
        bCorner.Parent = Badge

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = Color3.fromHex("#5A5A5A")
        bStroke.Thickness = 1
        bStroke.Transparency = 0.45
        bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bStroke.Parent = Badge

        local bPad = Instance.new("UIPadding")
        bPad.PaddingTop = UDim.new(0, 2)
        bPad.PaddingBottom = UDim.new(0, 2)
        bPad.PaddingLeft = UDim.new(0, 7)
        bPad.PaddingRight = UDim.new(0, 7)
        bPad.Parent = Badge

        local bLabel = Instance.new("TextLabel")
        bLabel.Font = Enum.Font.GothamBold
        bLabel.Text = text
        bLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        bLabel.TextSize = 11
        bLabel.TextTransparency = 0.12
        bLabel.BackgroundTransparency = 1
        bLabel.BorderSizePixel = 0
        bLabel.AutomaticSize = Enum.AutomaticSize.XY
        bLabel.Parent = Badge

        return Badge
    end

    local TitleWrapper = Instance.new("Frame")
    TitleWrapper.BackgroundTransparency = 1
    TitleWrapper.AutomaticSize = Enum.AutomaticSize.X
    TitleWrapper.Size = UDim2.new(0, 0, 1, 0)
    TitleWrapper.Position = UDim2.new(0, 8, 0, 0)
    TitleWrapper.Parent = Top

    local TitleWrapLayout = Instance.new("UIListLayout")
    TitleWrapLayout.FillDirection = Enum.FillDirection.Horizontal
    TitleWrapLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleWrapLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleWrapLayout.Padding = UDim.new(0, 8)
    TitleWrapLayout.Parent = TitleWrapper

    -- Icon (20x20)
    if Icon and Icon ~= "" then
        local IconImg = Instance.new("ImageLabel")
        IconImg.Image = Icon
        IconImg.BackgroundTransparency = 1
        IconImg.Size = UDim2.new(0, 20, 0, 20)
        IconImg.LayoutOrder = 0
        IconImg.Parent = TitleWrapper
    end

    local TitleColumn = Instance.new("Frame")
    TitleColumn.BackgroundTransparency = 1
    TitleColumn.AutomaticSize = Enum.AutomaticSize.XY
    TitleColumn.LayoutOrder = 1
    TitleColumn.Parent = TitleWrapper

    local TitleColLayout = Instance.new("UIListLayout")
    TitleColLayout.FillDirection = Enum.FillDirection.Vertical
    TitleColLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TitleColLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleColLayout.Padding = UDim.new(0, 1)
    TitleColLayout.Parent = TitleColumn

    local Row1 = Instance.new("Frame")
    Row1.BackgroundTransparency = 1
    Row1.AutomaticSize = Enum.AutomaticSize.XY
    Row1.LayoutOrder = 1
    Row1.Parent = TitleColumn

    local Row1Layout = Instance.new("UIListLayout")
    Row1Layout.FillDirection = Enum.FillDirection.Horizontal
    Row1Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Row1Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Row1Layout.Padding = UDim.new(0, 6)
    Row1Layout.Parent = Row1

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.AutomaticSize = Enum.AutomaticSize.XY
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.BorderSizePixel = 0
    TitleLabel.LayoutOrder = 1
    TitleLabel.Parent = Row1

    if Version and Version ~= "" then
        local vBadge = createBadge(Version, "VersionBadge")
        vBadge.LayoutOrder = 2
        vBadge.Parent = Row1
    end

    if ShowExecutor then
        local execName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Executor"
        local eBadge = createBadge(execName, "ExecutorBadge")
        eBadge.LayoutOrder = 3
        eBadge.Parent = Row1
    end

    local Subtitle = config.Subtitle or ""
    if Subtitle ~= "" then
        local SubtitleLabel = Instance.new("TextLabel")
        SubtitleLabel.Font = Enum.Font.Gotham
        SubtitleLabel.Text = Subtitle
        SubtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
        SubtitleLabel.TextSize = 11
        SubtitleLabel.TextTransparency = 0.35
        SubtitleLabel.AutomaticSize = Enum.AutomaticSize.XY
        SubtitleLabel.BackgroundTransparency = 1
        SubtitleLabel.BorderSizePixel = 0
        SubtitleLabel.LayoutOrder = 2
        SubtitleLabel.Parent = TitleColumn
    end

    local BadgeContainer = Instance.new("Frame")
    BadgeContainer.Name = "BadgeContainer"
    BadgeContainer.AnchorPoint = Vector2.new(1, 0.5)
    BadgeContainer.BackgroundTransparency = 1
    BadgeContainer.Size = UDim2.new(0, 160, 1, 0)
    BadgeContainer.Position = UDim2.new(1, -77, 0.5, 0)
    BadgeContainer.Parent = Top

    local BadgeLayout = Instance.new("UIListLayout")
    BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
    BadgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BadgeLayout.Padding = UDim.new(0, 6)
    BadgeLayout.Parent = BadgeContainer

    for _, badgeText in ipairs(Badges) do
        local Badge = Instance.new("TextLabel")
        Badge.Name = "Badge"
        Badge.Font = Enum.Font.GothamBold
        Badge.Text = badgeText
        Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
        Badge.TextSize = 14
        Badge.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        Badge.BackgroundTransparency = 0.3
        Badge.BorderSizePixel = 0
        Badge.Size =
            UDim2.new(
            0,
            TextService:GetTextSize(badgeText, 14, Enum.Font.GothamBold, Vector2.new(999, 999)).X + 18,
            0,
            24
        )

        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(1, 0)
        BadgeCorner.Parent = Badge

        Badge.Parent = BadgeContainer

        table.insert(
            ConfigSystem.ThemeElements,
            {
                Update = function(color)
                    Badge.BackgroundColor3 = color
                end
            }
        )
    end

    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.999
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://110786993356448"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseIcon.BackgroundTransparency = 0.999
    CloseIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseIcon.BorderSizePixel = 0
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = Close

    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.999
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -42, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://118026365011536"
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinIcon.BackgroundTransparency = 0.999
    MinIcon.ImageTransparency = 0.2
    MinIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MinIcon.BorderSizePixel = 0
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(1, -9, 1, -9)
    MinIcon.Parent = Min



    local ResizeHandle = nil
    if Resizable then
        ResizeHandle = Instance.new("TextButton")
        ResizeHandle.Name = "ResizeHandle"
        ResizeHandle.Text = ""
        ResizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ResizeHandle.BackgroundTransparency = 1
        ResizeHandle.BorderSizePixel = 0
        ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
        ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.Parent = Main

        local ResizeCorner = Instance.new("UICorner")
        ResizeCorner.CornerRadius = UDim.new(0, 3)
        ResizeCorner.Parent = ResizeHandle

        local ResizeIcon = Instance.new("ImageLabel")
        ResizeIcon.Name = "ResizeIcon"
        ResizeIcon.Image = "rbxassetid://116269596042539"
        ResizeIcon.BackgroundTransparency = 1
        ResizeIcon.AnchorPoint = Vector2.new(1, 1)
        ResizeIcon.Size = UDim2.new(0, 10, 0, 10)
        ResizeIcon.Position = UDim2.new(1, 0, 1, 0)
        ResizeIcon.Parent = ResizeHandle

        MakeResizable(
            ResizeHandle,
            DropShadowHolder,
            Vector2.new(250, 150),
            Vector2.new(1200, 900),
            function(newSize)
                Main.Size = UDim2.new(1, -47, 1, -47)
            end
        )
    end

    local TabFrame = Instance.new("Frame")
    TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabFrame.BackgroundTransparency = 0.999
    TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 9, 0, 43)
    TabFrame.Size = UDim2.new(0, 120, 1, -43)
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = Main

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = TabFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.ScrollBarThickness = 0
    TabScroll.Active = true
    TabScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabScroll.BackgroundTransparency = 0.999
    TabScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.BorderSizePixel = 0
    TabScroll.Position = UDim2.new(0, 0, 0, 36)
    TabScroll.Size = UDim2.new(1, 0, 1, -86)
    TabScroll.Name = "TabScroll"
    TabScroll.Parent = TabFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    local TabTopPadding = Instance.new("UIPadding")
    TabTopPadding.PaddingTop = UDim.new(0, 4)
    TabTopPadding.Parent = TabScroll

    -- Search bar
    local SearchBar = Instance.new("Frame")
    SearchBar.Name = "SearchBar"
    SearchBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBar.BackgroundTransparency = 0.93
    SearchBar.BorderSizePixel = 0
    SearchBar.Position = UDim2.new(0, 0, 0, 6)
    SearchBar.Size = UDim2.new(1, 0, 0, 30)
    SearchBar.ZIndex = 20
    SearchBar.Active = true
    SearchBar.Parent = TabFrame

    local SearchBarCorner = Instance.new("UICorner")
    SearchBarCorner.CornerRadius = UDim.new(0, 4)
    SearchBarCorner.Parent = SearchBar

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Image = "rbxassetid://109869955247116"
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Position = UDim2.new(0, 5, 0.5, 0)
    SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.ZIndex = 22
    SearchIcon.Parent = SearchBar

    local SearchTextBox = Instance.new("TextBox")
    SearchTextBox.Font = Enum.Font.Gotham
    SearchTextBox.PlaceholderText = "Search Features..."
    SearchTextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    SearchTextBox.Text = ""
    SearchTextBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    SearchTextBox.TextSize = 11
    SearchTextBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchTextBox.BackgroundTransparency = 1
    SearchTextBox.BorderSizePixel = 0
    SearchTextBox.Position = UDim2.new(0, 22, 0, 0)
    SearchTextBox.Size = UDim2.new(1, -24, 1, 0)
    SearchTextBox.ClearTextOnFocus = false
    SearchTextBox.ZIndex = 21
    SearchTextBox.Parent = SearchBar

    local SearchResults = Instance.new("ScrollingFrame")
    local SearchResultsLayout = nil  -- forward, assigned below
    SearchResults.Name = "SearchResults"
    SearchResults.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    SearchResults.BorderSizePixel = 0
    SearchResults.Position = UDim2.new(0, 9, 0, 75)
    SearchResults.Size = UDim2.new(0, 120, 0, 0)
    SearchResults.ScrollBarThickness = 2
    SearchResults.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 170)
    SearchResults.ClipsDescendants = true
    SearchResults.ZIndex = 50
    SearchResults.Visible = false
    SearchResults.CanvasSize = UDim2.new(0, 0, 0, 0)
    SearchResults.Parent = Main

    local SearchResultsCorner = Instance.new("UICorner")
    SearchResultsCorner.CornerRadius = UDim.new(0, 4)
    SearchResultsCorner.Parent = SearchResults

    SearchResultsLayout = Instance.new("UIListLayout")
    SearchResultsLayout.Padding = UDim.new(0, 2)
    SearchResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SearchResultsLayout.Parent = SearchResults

    SearchResultsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SearchResults.CanvasSize = UDim2.new(0, 0, 0, SearchResultsLayout.AbsoluteContentSize.Y + 4)
    end)

    local searchResultsOpen = false
    local NoResultsLabel = nil
    local SearchSections = {}
    local TabContents = {}
    local TabSwitchFns = {}
    local ContentScroll = nil
    -- helper: sum Size.Y.Offset of children above stopAt (reliable, no render needed)
    local function sumChildH(container, stopAt)
        local y = 0
        for _, ch in ipairs(container:GetChildren()) do
            if ch == stopAt then break end
            if ch:IsA("Frame") then y = y + ch.Size.Y.Offset + 8 end
        end
        return y
    end

    local function flashElem(elem)
        task.spawn(function()
            local s = Instance.new("UIStroke")
            s.Color = Color3.fromRGB(180, 180, 210)
            s.Thickness = 2.5
            s.Transparency = 0
            s.Parent = elem
            task.wait(0.8)
            if s and s.Parent then s:Destroy() end
        end)
    end

    local function closeSearchResults()
        searchResultsOpen = false
        SearchResults.Visible = false
        for _, child in ipairs(SearchResults:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        if NoResultsLabel then NoResultsLabel.Visible = false end
    end

    local function buildSearchResults(query)
        if not NoResultsLabel then return end
        -- fresh destroy old buttons
        for _, child in ipairs(SearchResults:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        NoResultsLabel.Visible = false

        if query == "" then
            closeSearchResults()
            return
        end

        local q = string.lower(query)
        local found = 0

        for _, sec in ipairs(SearchSections) do
            pcall(function()
                local inner = sec.secFrame and sec.secFrame:FindFirstChild("InnerContainer")
                if not inner then return end
                for _, elem in ipairs(inner:GetChildren()) do
                    for _, lname in ipairs({"ToggleTitle","ButtonTitle","InputTitle","DropdownTitle","SliderTitle","ParagraphTitle"}) do
                        local lbl = elem:FindFirstChild(lname)
                        if lbl and lbl.Text and lbl.Text ~= "" then
                            if string.find(string.lower(lbl.Text), q, 1, true) then
                                found = found + 1
                                local displayText = lbl.Text
                                local subtitleText = (sec.tabName or "") .. " \xE2\x80\xA2 " .. (sec.title or "")
                                local capSec = sec
                                local capElem = elem

                                local Item = Instance.new("TextButton", SearchResults)
                                Item.Font = Enum.Font.GothamBold
                                Item.Text = ""
                                Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Item.BackgroundTransparency = 0.92
                                Item.BorderSizePixel = 0
                                Item.Size = UDim2.new(1, 0, 0, 40)
                                Item.ZIndex = 51
                                Item.AutoButtonColor = true
                                Item.Visible = true
                                Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 3)

                                -- pill indicator left
                                local Pill = Instance.new("Frame", Item)
                                Pill.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
                                Pill.BorderSizePixel = 0
                                Pill.Position = UDim2.new(0, 0, 0.1, 0)
                                Pill.Size = UDim2.new(0, 2, 0.8, 0)
                                Pill.ZIndex = 52
                                Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

                                -- main text
                                local MainLabel = Instance.new("TextLabel", Item)
                                MainLabel.Font = Enum.Font.GothamBold
                                MainLabel.Text = displayText
                                MainLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                                MainLabel.TextSize = 13
                                MainLabel.TextXAlignment = Enum.TextXAlignment.Left
                                MainLabel.TextTruncate = Enum.TextTruncate.AtEnd
                                MainLabel.BackgroundTransparency = 1
                                MainLabel.BorderSizePixel = 0
                                MainLabel.Position = UDim2.new(0, 8, 0, 4)
                                MainLabel.Size = UDim2.new(1, -10, 0, 16)
                                MainLabel.ZIndex = 52

                                -- subtitle
                                local SubLabel = Instance.new("TextLabel", Item)
                                SubLabel.Font = Enum.Font.Gotham
                                SubLabel.Text = subtitleText
                                SubLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
                                SubLabel.TextSize = 9
                                SubLabel.TextXAlignment = Enum.TextXAlignment.Left
                                SubLabel.TextTruncate = Enum.TextTruncate.AtEnd
                                SubLabel.BackgroundTransparency = 1
                                SubLabel.BorderSizePixel = 0
                                SubLabel.Position = UDim2.new(0, 8, 0, 22)
                                SubLabel.Size = UDim2.new(1, -10, 0, 12)
                                SubLabel.ZIndex = 52

                                Item.MouseButton1Click:Connect(function()
                                    task.spawn(function()
                                        local sf = TabSwitchFns[capSec.tabName]
                                        if sf then pcall(sf) end
                                        pcall(capSec.openFn)
                                        task.wait(0.2)
                                        -- reliable scroll: sum child heights
                                        local cont = TabContents[capSec.tabName]
                                        local inner3 = capSec.secFrame and capSec.secFrame:FindFirstChild("InnerContainer")
                                        local secOffset = cont and sumChildH(cont, capSec.secFrame) or 0
                                        local elemOffset = inner3 and sumChildH(inner3, capElem) or 0
                                        local scrollTo = secOffset + 34 + elemOffset
                                        ContentScroll.CanvasPosition = Vector2.new(0, scrollTo)
                                        flashElem(capElem)
                                    end)
                                    SearchTextBox.Text = ""
                                    closeSearchResults()
                                end)
                            end
                            break
                        end
                    end
                end
            end)
        end

        -- second pass: scan elements directly in tabs (outside collapsibles)
        for tabName, container in pairs(TabContents or {}) do
            for _, elem in ipairs(container:GetChildren()) do
                if elem.Name ~= "Collapsible" then
                    for _, lname in ipairs({"ToggleTitle","ButtonTitle","InputTitle","DropdownTitle","SliderTitle","ParagraphTitle"}) do
                        local lbl = elem:FindFirstChild(lname)
                        if lbl and lbl.Text and lbl.Text ~= "" then
                            if string.find(string.lower(lbl.Text), q, 1, true) then
                                found = found + 1
                                local displayText = lbl.Text
                                local subtitleText = tabName .. " \xE2\x80\xA2 " .. tabName
                                local capTab = tabName
                                local capElem = elem

                                local Item = Instance.new("TextButton", SearchResults)
                                Item.Font = Enum.Font.GothamBold
                                Item.Text = ""
                                Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                Item.BackgroundTransparency = 0.92
                                Item.BorderSizePixel = 0
                                Item.Size = UDim2.new(1, 0, 0, 40)
                                Item.ZIndex = 51
                                Item.AutoButtonColor = true
                                Item.Visible = true
                                Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 3)
                                local Pill2 = Instance.new("Frame", Item)
                                Pill2.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
                                Pill2.BorderSizePixel = 0
                                Pill2.Position = UDim2.new(0, 0, 0.1, 0)
                                Pill2.Size = UDim2.new(0, 2, 0.8, 0)
                                Pill2.ZIndex = 52
                                Instance.new("UICorner", Pill2).CornerRadius = UDim.new(1, 0)
                                local ML2 = Instance.new("TextLabel", Item)
                                ML2.Font = Enum.Font.GothamBold
                                ML2.Text = displayText
                                ML2.TextColor3 = Color3.fromRGB(220, 220, 220)
                                ML2.TextSize = 13
                                ML2.TextXAlignment = Enum.TextXAlignment.Left
                                ML2.TextTruncate = Enum.TextTruncate.AtEnd
                                ML2.BackgroundTransparency = 1
                                ML2.BorderSizePixel = 0
                                ML2.Position = UDim2.new(0, 8, 0, 4)
                                ML2.Size = UDim2.new(1, -10, 0, 16)
                                ML2.ZIndex = 52
                                local SL2 = Instance.new("TextLabel", Item)
                                SL2.Font = Enum.Font.Gotham
                                SL2.Text = subtitleText
                                SL2.TextColor3 = Color3.fromRGB(120, 120, 140)
                                SL2.TextSize = 9
                                SL2.TextXAlignment = Enum.TextXAlignment.Left
                                SL2.TextTruncate = Enum.TextTruncate.AtEnd
                                SL2.BackgroundTransparency = 1
                                SL2.BorderSizePixel = 0
                                SL2.Position = UDim2.new(0, 8, 0, 22)
                                SL2.Size = UDim2.new(1, -10, 0, 12)
                                SL2.ZIndex = 52
                                Item.MouseButton1Click:Connect(function()
                                    task.spawn(function()
                                        local sf = TabSwitchFns[capTab]
                                        if sf then pcall(sf) end
                                        task.wait(0.2)
                                        local cont = TabContents[capTab]
                                        local scrollTo = cont and sumChildH(cont, capElem) or 0
                                        ContentScroll.CanvasPosition = Vector2.new(0, scrollTo)
                                        flashElem(capElem)
                                    end)
                                    SearchTextBox.Text = ""
                                    closeSearchResults()
                                end)
                            end
                            break
                        end
                    end
                end
            end
        end

        if found == 0 then
            NoResultsLabel.Visible = true
        end

        -- defer so UIListLayout computes AbsoluteContentSize after items added
        task.defer(function()
            local contentH = SearchResultsLayout.AbsoluteContentSize.Y + 4
            if found == 0 then contentH = 30 end
            local targetH = math.max(30, math.min(contentH, 150))
            SearchResults.CanvasSize = UDim2.new(0, 0, 0, contentH)
            SearchResults.Size = UDim2.new(0, 120, 0, targetH)
            SearchResults.Visible = true
            searchResultsOpen = true
        end)
    end


    -- NoResults label (hidden by default)
    NoResultsLabel = Instance.new("TextLabel", SearchResults)
    NoResultsLabel.Name = "NoResults"
    NoResultsLabel.Text = "  No results"
    NoResultsLabel.Font = Enum.Font.Gotham
    NoResultsLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
    NoResultsLabel.TextSize = 11
    NoResultsLabel.TextXAlignment = Enum.TextXAlignment.Left
    NoResultsLabel.BackgroundTransparency = 1
    NoResultsLabel.BorderSizePixel = 0
    NoResultsLabel.Size = UDim2.new(1, 0, 0, 26)
    NoResultsLabel.ZIndex = 51
    NoResultsLabel.Visible = false

    pcall(function()
        SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
            buildSearchResults(SearchTextBox.Text)
        end)
    end)

    -- polling backup (for executors where GetPropertyChangedSignal fails)
    local _lastTxt = ""
    task.spawn(function()
        while true do
            task.wait(0.1)
            if not SearchTextBox or not SearchTextBox.Parent then break end
            local t = SearchTextBox.Text
            if t ~= _lastTxt then
                _lastTxt = t
                pcall(buildSearchResults, t)
            end
        end
    end)

    SearchTextBox.FocusLost:Connect(function()
        if SearchTextBox.Text == "" then closeSearchResults() end
    end)

    -- Player footer
    local PlayerFooter = Instance.new("Frame")
    PlayerFooter.Name = "PlayerFooter"
    PlayerFooter.BackgroundTransparency = 1
    PlayerFooter.Position = UDim2.new(0, 0, 1, -46)
    PlayerFooter.Size = UDim2.new(1, 0, 0, 42)
    PlayerFooter.BorderSizePixel = 0
    PlayerFooter.Parent = TabFrame

    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Position = UDim2.new(0, 5, 0.5, 0)
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.Size = UDim2.new(0, 32, 0, 32)
    AvatarContainer.BorderSizePixel = 0
    AvatarContainer.Parent = PlayerFooter

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.Image = "rbxassetid://0"
    AvatarImg.Parent = AvatarContainer

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImg

    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Color = Color3.fromRGB(120, 120, 135)
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Transparency = 0.2
    AvatarStroke.Parent = AvatarImg

    pcall(function()
        local lp = Players.LocalPlayer
        local content, isReady = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)

    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Name = "WelcomeLabel"
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 43, 0.5, -8)
    WelcomeLabel.AnchorPoint = Vector2.new(0, 0)
    WelcomeLabel.Size = UDim2.new(1, -47, 0, 13)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    WelcomeLabel.TextSize = 11
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = false
    WelcomeLabel.Text = "Welcome,"
    WelcomeLabel.Visible = false
    WelcomeLabel.Parent = PlayerFooter

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Position = UDim2.new(0, 43, 0.5, 0)
    UsernameLabel.AnchorPoint = Vector2.new(0, 0.5)
    UsernameLabel.Size = UDim2.new(1, -47, 0, 13)
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    UsernameLabel.TextSize = 11
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextWrapped = false
    UsernameLabel.Text = "usr***"
    UsernameLabel.Parent = PlayerFooter

    local maskedName = "usr***"
    pcall(function()
        local rawName = tostring(Players.LocalPlayer.Name)
        maskedName = string.sub(rawName, 1, 3) .. "***"
        UsernameLabel.Text = maskedName
    end)

    -- Dynamic footer: 1 line when small, 2 lines when large
    local function UpdateFooterLayout()
        local h = Main.AbsoluteSize.Y
        if h > 300 then
            -- 2 labels
            WelcomeLabel.Visible = true
            WelcomeLabel.Position = UDim2.new(0, 43, 0.5, -8)
            UsernameLabel.Position = UDim2.new(0, 43, 0.5, 3)
            UsernameLabel.AnchorPoint = Vector2.new(0, 0)
            UsernameLabel.Text = maskedName
        else
            -- 1 label: "Welcome, usr***"
            WelcomeLabel.Visible = false
            UsernameLabel.Position = UDim2.new(0, 43, 0.5, 0)
            UsernameLabel.AnchorPoint = Vector2.new(0, 0.5)
            UsernameLabel.Text = "Welcome, " .. maskedName
        end
    end

    Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateFooterLayout)
    task.defer(UpdateFooterLayout)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentFrame.BackgroundTransparency = 0.999
    ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 138, 0, 43)
    ContentFrame.Size = UDim2.new(1, -147, 1, -43)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = Main

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 2)
    ContentCorner.Parent = ContentFrame

    if WatermarkAsset then
        local WMLabel = Instance.new("ImageLabel")
        WMLabel.Name = "Watermark"
        WMLabel.Size = UDim2.fromOffset(WatermarkSize, math.floor(WatermarkSize * 496 / 512 + 0.5))
        WMLabel.Position = UDim2.new(0.5, 0, 1, 0)
        WMLabel.AnchorPoint = Vector2.new(0.5, 1)
        WMLabel.BackgroundTransparency = 1
        WMLabel.Image = WatermarkAsset
        WMLabel.ImageTransparency = WatermarkTransparency or 0.94
        WMLabel.ScaleType = Enum.ScaleType.Fit
        WMLabel.ZIndex = 0
        WMLabel.Parent = ContentFrame
    end

    ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ContentScroll.ScrollBarThickness = 0
    ContentScroll.Active = true
    ContentScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentScroll.BackgroundTransparency = 0.999
    ContentScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ClipsDescendants = true
    ContentScroll.Position = UDim2.new(0, 0, 0, 6)
    ContentScroll.Size = UDim2.new(1, 0, 1, -6)
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Parent = ContentFrame



    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentScroll

    TabContents = {}
    local CurrentTab = nil
    local TabCount = 0
    local AllElements = {}
    TabSwitchFns = {}

    local function UpdateTabSize()
        local OffsetY = 0
        for _, child in TabScroll:GetChildren() do
            if child:IsA("Frame") then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end

    local function UpdateContentSize()
        if CurrentTab and TabContents[CurrentTab] then
            local OffsetY = 0
            for _, child in TabContents[CurrentTab]:GetChildren() do
                if child:IsA("Frame") then
                    OffsetY = OffsetY + 8 + child.Size.Y.Offset
                end
            end
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
        end
    end

    TabScroll.ChildAdded:Connect(UpdateTabSize)
    TabScroll.ChildRemoved:Connect(UpdateTabSize)

    setupCloseModal(Close, Main, ScreenGui)

    Min.Activated:Connect(
        function()
            CircleClick(Min, Mouse.X, Mouse.Y)
            DropShadowHolder.Visible = false
        end
    )

    UserInputService.InputBegan:Connect(
        function(input)
            if input.KeyCode == MinimizeKey then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
            end
        end
    )

    if Draggable then
        MakeDraggable(Top, DropShadowHolder)
    end

    local ToggleBtn = nil
    local enableToggleBtn = (config.ToggleButton ~= false) or (config.MinimizeButton == true)

    if enableToggleBtn then
        ToggleBtn = Instance.new("Frame")
        ToggleBtn.Name = "LimboToggleButton"
        ToggleBtn.BackgroundColor3 = Color3.fromHex("#141414")
        ToggleBtn.BackgroundTransparency = 0
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Size = UDim2.fromOffset(44, 44)
        ToggleBtn.Position = UDim2.new(0.015, 0, 0.1, 0)
        ToggleBtn.ZIndex = 10000
        ToggleBtn.Parent = ScreenGui

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 11)
        ButtonCorner.Parent = ToggleBtn

        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Thickness = 1
        ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        ButtonStroke.Color = Color3.fromHex("#FF00E0")
        ButtonStroke.Transparency = 0.15
        ButtonStroke.Parent = ToggleBtn

        local ButtonGradient = Instance.new("UIGradient")
        ButtonGradient.Color = ColorSequence.new(Color3.fromHex("#FF00E0"), Color3.fromHex("#FF00E0"))
        ButtonGradient.Parent = ButtonStroke

        local ButtonImage = Instance.new("ImageLabel")
        ButtonImage.Name = "ButtonImage"
        ButtonImage.Image = "rbxthumb://type=Asset&id=93432513909214&w=420&h=420"
        ButtonImage.BackgroundTransparency = 1
        ButtonImage.Size = UDim2.fromOffset(30, 30)
        ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5)
        ButtonImage.Position = UDim2.fromScale(0.5, 0.5)
        ButtonImage.ScaleType = Enum.ScaleType.Fit
        ButtonImage.ZIndex = 10001
        ButtonImage.Active = false
        ButtonImage.Parent = ToggleBtn

        local TBSurface = Instance.new("Frame", ToggleBtn)
        TBSurface.Name = "TBSurface"
        TBSurface.BackgroundTransparency = 1
        TBSurface.Size = UDim2.new(1, 0, 1, 0)
        TBSurface.ZIndex = 10002
        TBSurface.Active = true

        local dragging, dragged, dragStart, startPos = false, false, nil, nil
        local clickStartPos = nil

        TBSurface.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragged = false
                dragStart = input.Position
                clickStartPos = input.Position
                startPos = ToggleBtn.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local delta = input.Position - dragStart
            if not dragged and clickStartPos and (input.Position - clickStartPos).Magnitude > 6 then
                dragged = true
            end
            if not dragged then return end
            local ss = ScreenGui.AbsoluteSize
            local bs = ToggleBtn.AbsoluteSize
            local pad = 10
            ToggleBtn.Position = UDim2.new(0,
                math.clamp(startPos.X.Offset + delta.X, pad, ss.X - bs.X - pad),
                0,
                math.clamp(startPos.Y.Offset + delta.Y, pad, ss.Y - bs.Y - pad))
        end)

        local lastClick = 0
        TBSurface.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if dragging and not dragged then
                    local now = workspace.DistributedGameTime
                    if now - lastClick >= 0.2 then
                        lastClick = now
                        DropShadowHolder.Visible = not DropShadowHolder.Visible
                    end
                end
                dragging = false
                dragged = false
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- Element Creation Functions
    local function CreateParagraph(tabContainer, title, content)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Paragraph = Instance.new("Frame")
        Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Paragraph.BackgroundTransparency = 0.935
        Paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Paragraph.BorderSizePixel = 0
        Paragraph.Size = UDim2.new(1, 0, 0, 46)
        Paragraph.Name = "Paragraph"
        Paragraph.Parent = tabContainer

        local ParagraphCorner = Instance.new("UICorner")
        ParagraphCorner.CornerRadius = UDim.new(0, 4)
        ParagraphCorner.Parent = Paragraph

        local ParagraphTitle = Instance.new("TextLabel")
        ParagraphTitle.Font = Enum.Font.GothamBold
        ParagraphTitle.Text = title
        ParagraphTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ParagraphTitle.TextSize = 14
        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphTitle.BackgroundTransparency = 0.999
        ParagraphTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ParagraphTitle.BorderSizePixel = 0
        ParagraphTitle.Position = UDim2.new(0, 10, 0, 10)
        ParagraphTitle.Size = UDim2.new(1, -20, 0, 13)
        ParagraphTitle.Name = "ParagraphTitle"
        ParagraphTitle.Parent = Paragraph

        local ParagraphContent = Instance.new("TextLabel")
        ParagraphContent.Font = Enum.Font.GothamBold
        ParagraphContent.Text = content
        ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.TextSize = 13
        ParagraphContent.TextTransparency = 0.6
        ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ParagraphContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.BackgroundTransparency = 0.999
        ParagraphContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ParagraphContent.BorderSizePixel = 0
        ParagraphContent.Position = UDim2.new(0, 10, 0, 23)
        ParagraphContent.Name = "ParagraphContent"
        ParagraphContent.Parent = Paragraph

        local scrollWidth = ContentScroll.AbsoluteSize.X
        local textWidth = scrollWidth > 0 and (scrollWidth - 40) or 290
        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(textWidth, math.huge)
        )

        ParagraphContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        ParagraphContent.TextWrapped = true
        ParagraphContent.AutomaticSize = Enum.AutomaticSize.Y
        Paragraph.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 50))
        Paragraph.AutomaticSize = Enum.AutomaticSize.Y

        UpdateContentSize()

        return Paragraph
    end

    local function CreateButton(tabContainer, title, content, iconId, callback)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 46)
        Button.Name = "Button"
        Button.Parent = tabContainer

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button

        local ButtonTitle = Instance.new("TextLabel")
        ButtonTitle.Font = Enum.Font.GothamBold
        ButtonTitle.Text = title
        ButtonTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ButtonTitle.TextSize = 14
        ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
        ButtonTitle.TextYAlignment = Enum.TextYAlignment.Top
        ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonTitle.BackgroundTransparency = 0.999
        ButtonTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonTitle.BorderSizePixel = 0
        ButtonTitle.Position = UDim2.new(0, 10, 0, 10)
        ButtonTitle.Size = UDim2.new(1, -100, 0, 13)
        ButtonTitle.Name = "ButtonTitle"
        ButtonTitle.Parent = Button

        local ButtonContent = Instance.new("TextLabel")
        ButtonContent.Font = Enum.Font.GothamBold
        ButtonContent.Text = content
        ButtonContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.TextSize = 13
        ButtonContent.TextTransparency = 0.6
        ButtonContent.TextXAlignment = Enum.TextXAlignment.Left
        ButtonContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ButtonContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.BackgroundTransparency = 0.999
        ButtonContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonContent.BorderSizePixel = 0
        ButtonContent.Position = UDim2.new(0, 10, 0, 23)
        ButtonContent.Name = "ButtonContent"
        ButtonContent.Parent = Button

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ButtonContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ButtonContent.TextWrapped = true
        Button.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ButtonButton = Instance.new("TextButton")
        ButtonButton.Font = Enum.Font.SourceSans
        ButtonButton.Text = ""
        ButtonButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.TextSize = 14
        ButtonButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BackgroundTransparency = 0.999
        ButtonButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BorderSizePixel = 0
        ButtonButton.Size = UDim2.new(1, 0, 1, 0)
        ButtonButton.Name = "ButtonButton"
        ButtonButton.Parent = Button

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BackgroundTransparency = 0.999
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -17, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 18, 0, 18)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Button

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = ResolveIcon(iconId) or "rbxassetid://16932740082"
        FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.999
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        FeatureImg.Size = UDim2.new(1, 0, 1, 0)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = FeatureFrame

        ButtonButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(ButtonButton, Mouse.X, Mouse.Y)
                if callback then
                    callback()
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        return Button
    end

    local function CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Toggle = Instance.new("Frame")
        Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.BackgroundTransparency = 0.935
        Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        Toggle.Name = "Toggle"
        Toggle.Parent = tabContainer

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = Toggle

        local ToggleTitle = Instance.new("TextLabel")
        ToggleTitle.Font = Enum.Font.GothamBold
        ToggleTitle.Text = title
        ToggleTitle.TextSize = 14
        ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
        ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.BackgroundTransparency = 0.999
        ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleTitle.BorderSizePixel = 0
        ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
        ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Parent = Toggle

        local ToggleContent = Instance.new("TextLabel")
        ToggleContent.Font = Enum.Font.GothamBold
        ToggleContent.Text = content
        ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleContent.TextSize = 13
        ToggleContent.TextTransparency = 0.6
        ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
        ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ToggleContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleContent.BackgroundTransparency = 0.999
        ToggleContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleContent.BorderSizePixel = 0
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleContent.Size = UDim2.new(1, -100, 0, 12)
        ToggleContent.Name = "ToggleContent"
        ToggleContent.Parent = Toggle

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ToggleContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ToggleContent.TextWrapped = true
        Toggle.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BackgroundTransparency = 0.999
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        FeatureFrame.BackgroundTransparency = 0.2
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -10, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 36, 0, 18)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Toggle

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.Parent = FeatureFrame

        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        ToggleCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Position = defaultValue and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 1, 0.5, -7)
        ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Parent = FeatureFrame

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(0, 15)
        CircleCorner.Parent = ToggleCircle

        table.insert(ConfigSystem.ToggleElements, Toggle)

        local state = defaultValue or false
        local activeTweens = {}

        local function CancelToggleTweens()
            for i = 1, #activeTweens do
                local tween = activeTweens[i]
                if tween then
                    pcall(function() tween:Cancel() end)
                end
            end
            table.clear(activeTweens)
        end

        local function ApplyToggleVisual(value, animated)
            CancelToggleTweens()

            local themeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            local titleProps
            local circleProps
            local frameProps

            if value then
                titleProps = {TextColor3 = themeColor}
                circleProps = {
                    Position = UDim2.new(1, -15, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                }
                frameProps = {
                    BackgroundColor3 = themeColor,
                    BackgroundTransparency = 0
                }
            else
                titleProps = {TextColor3 = Color3.fromRGB(230, 230, 230)}
                circleProps = {
                    Position = UDim2.new(0, 1, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                }
                frameProps = {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    BackgroundTransparency = 0.2
                }
            end

            if animated then
                local tweenInfo = TweenInfo.new(
                    0.2,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.InOut
                )
                activeTweens[1] = TweenService:Create(ToggleTitle, tweenInfo, titleProps)
                activeTweens[2] = TweenService:Create(ToggleCircle, tweenInfo, circleProps)
                activeTweens[3] = TweenService:Create(FeatureFrame, tweenInfo, frameProps)

                for i = 1, #activeTweens do
                    activeTweens[i]:Play()
                end
            else
                for property, value2 in pairs(titleProps) do
                    ToggleTitle[property] = value2
                end
                for property, value2 in pairs(circleProps) do
                    ToggleCircle[property] = value2
                end
                for property, value2 in pairs(frameProps) do
                    FeatureFrame[property] = value2
                end
            end
        end

        local function SetState(value, fireCallback)
            state = value == true
            ApplyToggleVisual(state, fireCallback ~= false)
            if fireCallback ~= false and callback then
                callback(state)
            end
        end

        SetState(state, false)

        ToggleButton.Activated:Connect(
            function()
                CircleClick(ToggleButton, Mouse.X, Mouse.Y)
                SetState(not state)
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local toggleFunc = {
            Value = state,
            _live = function() return state end,
            Type = "Toggle",
            Id = elementId
        }

        function toggleFunc:Set(value)
            state = value
            local themeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            pcall(function()
                if value then
                    ToggleTitle.TextColor3 = themeColor
                    ToggleCircle.Position = UDim2.new(1, -15, 0.5, -7)
                    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    FeatureFrame.BackgroundColor3 = themeColor
                    FeatureFrame.BackgroundTransparency = 0
                else
                    ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
                    ToggleCircle.Position = UDim2.new(0, 1, 0.5, -7)
                    ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    FeatureFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    FeatureFrame.BackgroundTransparency = 0.2
                end
            end)
            if callback then pcall(callback, value) end
        end

        if elementId then
            AllElements[elementId] = toggleFunc
            table.insert(Limbo._resetCallbacks, function() toggleFunc.Set(false) end)
        end

        return toggleFunc
    end

    local function CreateInput(tabContainer, title, content, placeholder, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local Input = Instance.new("Frame")
        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Input.BackgroundTransparency = 0.935
        Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Input.BorderSizePixel = 0
        Input.Size = UDim2.new(1, 0, 0, 64)
        Input.Name = "Input"
        Input.Parent = tabContainer

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = Input

        local InputTitle = Instance.new("TextLabel")
        InputTitle.Font = Enum.Font.GothamBold
        InputTitle.Text = title
        InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        InputTitle.TextSize = 14
        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
        InputTitle.BackgroundTransparency = 0.999
        InputTitle.BorderSizePixel = 0
        InputTitle.Position = UDim2.new(0, 8, 0, 6)
        InputTitle.Size = UDim2.new(1, -16, 0, 14)
        InputTitle.Name = "InputTitle"
        InputTitle.Parent = Input
        if content and content ~= "" then
            local InputContent = Instance.new("TextLabel")
            InputContent.Font = Enum.Font.Gotham
            InputContent.Text = content
            InputContent.TextColor3 = Color3.fromRGB(180, 180, 180)
            InputContent.TextTransparency = 0.3
            InputContent.TextSize = 11
            InputContent.TextXAlignment = Enum.TextXAlignment.Left
            InputContent.BackgroundTransparency = 0.999
            InputContent.BorderSizePixel = 0
            InputContent.Position = UDim2.new(0, 8, 0, 22)
            InputContent.Size = UDim2.new(1, -16, 0, 12)
            InputContent.Name = "InputContent"
            InputContent.Parent = Input
        end
        local InputFrame = Instance.new("Frame")
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.AnchorPoint = Vector2.new(0, 0)
        InputFrame.Position = UDim2.new(0, 6, 0, 28)
        InputFrame.Size = UDim2.new(1, -12, 0, 30)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = InputFrame

        local InputTextBox = Instance.new("TextBox")
        InputTextBox.ClearTextOnFocus = false
        InputTextBox.CursorPosition = -1
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputTextBox.PlaceholderText = placeholder or "Write your input there"
        InputTextBox.Text = ""
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 13
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.BackgroundTransparency = 0.999
        InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -10, 1, -4)
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame

        local inputFunc = {
            Value = "",
            Type = "Input",
            Id = elementId
        }

        function inputFunc:Set(value)
            InputTextBox.Text = value
            inputFunc.Value = value
            if callback then
                callback(value)
            end
        end

        InputTextBox.FocusLost:Connect(function()
            inputFunc:Set(InputTextBox.Text)
        end)

        task.wait(0.1)
        UpdateContentSize()

        if elementId then
            AllElements[elementId] = inputFunc
        end

        return inputFunc
    end
    
    local function CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        local Dropdown = Instance.new("Frame")
        Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.BackgroundTransparency = 0.935
        Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Dropdown.BorderSizePixel = 0
        Dropdown.Size = UDim2.new(1, 0, 0, 46)
        Dropdown.Name = "Dropdown"
        Dropdown.Parent = tabContainer

        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 4)
        DropdownCorner.Parent = Dropdown

        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Font = Enum.Font.SourceSans
        DropdownButton.Text = ""
        DropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.TextSize = 14
        DropdownButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BackgroundTransparency = 0.999
        DropdownButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.ZIndex = 13
        DropdownButton.Name = "DropdownButton"
        DropdownButton.Parent = Dropdown

        local DropdownTitle = Instance.new("TextLabel")
        DropdownTitle.Font = Enum.Font.GothamBold
        DropdownTitle.Text = title
        DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        DropdownTitle.TextSize = 14
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        DropdownTitle.TextYAlignment = Enum.TextYAlignment.Top
        DropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DropdownTitle.BackgroundTransparency = 0.999
        DropdownTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownTitle.BorderSizePixel = 0
        DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
        DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
        DropdownTitle.Name = "DropdownTitle"
        DropdownTitle.Parent = Dropdown

        local DropdownContent = Instance.new("TextLabel")
        DropdownContent.Font = Enum.Font.GothamBold
        DropdownContent.Text = content
        DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownContent.TextSize = 13
        DropdownContent.TextTransparency = 0.6
        DropdownContent.TextWrapped = true
        DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
        DropdownContent.TextYAlignment = Enum.TextYAlignment.Bottom
        DropdownContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DropdownContent.BackgroundTransparency = 0.999
        DropdownContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownContent.BorderSizePixel = 0
        DropdownContent.Position = UDim2.new(0, 10, 0, 23)
        DropdownContent.Size = UDim2.new(1, -180, 0, 12)
        DropdownContent.Name = "DropdownContent"
        DropdownContent.Parent = Dropdown

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 200, math.huge)
        )

        DropdownContent.Size = UDim2.new(1, -180, 0, textSize.Y)
        DropdownContent.TextWrapped = true
        Dropdown.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local SelectOptionsFrame = Instance.new("Frame")
        SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
        SelectOptionsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectOptionsFrame.BackgroundTransparency = 0.95
        SelectOptionsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SelectOptionsFrame.BorderSizePixel = 0
        SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
        SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
        SelectOptionsFrame.Name = "SelectOptionsFrame"
        SelectOptionsFrame.Parent = Dropdown

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = SelectOptionsFrame

        local OptionSelecting = Instance.new("TextLabel")
        OptionSelecting.Font = Enum.Font.GothamBold
        OptionSelecting.Text = "Select Option"
        OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.TextSize = 13
        OptionSelecting.TextTransparency = 0.6
        OptionSelecting.TextWrapped = true
        OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
        OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
        OptionSelecting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.BackgroundTransparency = 0.999
        OptionSelecting.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionSelecting.BorderSizePixel = 0
        OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
        OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
        OptionSelecting.Name = "OptionSelecting"
        OptionSelecting.Parent = SelectOptionsFrame

        local OptionImg = Instance.new("ImageLabel")
        OptionImg.Image = "rbxassetid://16851841101"
        OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
        OptionImg.AnchorPoint = Vector2.new(1, 0.5)
        OptionImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionImg.BackgroundTransparency = 0.999
        OptionImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionImg.BorderSizePixel = 0
        OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
        OptionImg.Size = UDim2.new(0, 25, 0, 25)
        OptionImg.Name = "OptionImg"
        OptionImg.Parent = SelectOptionsFrame

        local DropdownList = Instance.new("Frame")
        DropdownList.AnchorPoint = Vector2.new(0, 0)
        DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownList.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownList.BorderSizePixel = 0
        DropdownList.Position = UDim2.new(1, -12, 0, 35)
        DropdownList.Size = UDim2.new(0, 160, 0, 0)
        DropdownList.Name = "DropdownList"
        DropdownList.Visible = false
        DropdownList.ClipsDescendants = true
        DropdownList.ZIndex = 10
        DropdownList.Parent = Main

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 2)
        ListCorner.Parent = DropdownList

        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Color3.fromRGB(255, 255, 255)
        ListStroke.Thickness = 2.5
        ListStroke.Transparency = 0.8
        ListStroke.Parent = DropdownList

        local ListScroll = Instance.new("ScrollingFrame")
        ListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.ScrollBarThickness = 0
        ListScroll.Active = true
        ListScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ListScroll.BackgroundTransparency = 0.999
        ListScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.BorderSizePixel = 0
        ListScroll.Size = UDim2.new(1, -10, 1, -50)
        ListScroll.Position = UDim2.new(0, 5, 0, 40)
        ListScroll.Name = "ListScroll"
        ListScroll.ZIndex = 11
        ListScroll.Parent = DropdownList

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 3)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = ListScroll

        -- ====== SEARCH INPUT ======
        local SearchFrame = Instance.new("Frame")
        SearchFrame.BackgroundTransparency = 1
        SearchFrame.BorderSizePixel = 0
        SearchFrame.Size = UDim2.new(1, 0, 0, 34)
        SearchFrame.Position = UDim2.new(0, 0, 0, 0)
        SearchFrame.ZIndex = 12
        SearchFrame.Name = "SearchFrame"
        SearchFrame.Parent = DropdownList

        local SearchInput = Instance.new("TextBox")
        SearchInput.Font = Enum.Font.Gotham
        SearchInput.PlaceholderText = "Search..."
        SearchInput.Text = ""
        SearchInput.TextSize = 12
        SearchInput.TextColor3 = Color3.fromRGB(230, 230, 230)
        SearchInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        SearchInput.TextXAlignment = Enum.TextXAlignment.Center
        SearchInput.BackgroundTransparency = 1
        SearchInput.BorderSizePixel = 0
        SearchInput.Size = UDim2.new(1, -16, 1, -8)
        SearchInput.Position = UDim2.new(0, 10, 0, 4)
        SearchInput.ZIndex = 13
        SearchInput.ClearTextOnFocus = false
        SearchInput.MultiLine = false
        SearchInput.Name = "SearchInput"
        SearchInput.Parent = SearchFrame

        local function ResetSearch()
            SearchInput.Text = ""
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    child.Visible = true
                end
            end
        end

        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local query = SearchInput.Text:lower()
            local totalH = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    local optText = child:FindFirstChild("OptionText")
                    local match = query == "" or (optText and optText.Text:lower():find(query, 1, true) ~= nil)
                    child.Visible = match
                    if match then totalH = totalH + child.Size.Y.Offset + 3 end
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalH)
        end)

        table.insert(ConfigSystem.DropdownElements, Dropdown)

        local dropdownData = {
            Options = options or {},
            Value = multi and (defaultValue or {}) or defaultValue or nil,
            Multi = multi ~= false and multi ~= nil,
            MaxSelect = type(multi) == "number" and multi or math.huge,
            Open = false,
            OptionFrames = {}
        }

        local function UpdateListSize()
            local totalHeight = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.Size.Y.Offset + 3
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            DropdownList.Size = UDim2.new(0, 160, 0, math.min(150, totalHeight + 10))
        end

        local function UpdateSelectedDisplay()
            if dropdownData.Multi then
                if #dropdownData.Value > 0 then
                    local displayText = ""
                    for i, v in ipairs(dropdownData.Value) do
                        if i > 3 then
                            displayText = displayText .. ", ..."
                            break
                        end
                        displayText = displayText .. (i > 1 and ", " or "") .. v
                    end
                    OptionSelecting.Text = displayText
                else
                    OptionSelecting.Text = "Select Option"
                end
            else
                OptionSelecting.Text = dropdownData.Value or "Select Option"
            end
        end


        local csConn = nil
        local function ToggleDropdown()
            dropdownData.Open = not dropdownData.Open
            if dropdownData.Open then
                local cfW    = ContentFrame.AbsoluteSize.X
                local halfCF = math.floor(cfW / 2)
                local rightW = cfW - halfCF - 4
                local targetH = math.floor(Main.AbsoluteSize.Y - 16)
                DropdownList.Position = UDim2.new(0, 138 + halfCF + rightW, 0, 8)
                DropdownList.Size = UDim2.new(0, 0, 0, targetH)
                DropdownList.Visible = true
                TweenService:Create(DropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, rightW, 0, targetH),
                    Position = UDim2.new(0, 138 + halfCF, 0, 8)
                }):Play()
                -- Close any other open dropdown first
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end

                -- Stores close fn for this dropdown
                Limbo._activeDropdownClose = function()
                    if not dropdownData.Open then return end
                    dropdownData.Open = false
                    ResetSearch()
                    DropdownList.Visible = false
                    Limbo._activeDropdownClose = nil
                    if csConn then csConn:Disconnect(); csConn = nil end
                    local dOvr = Main:FindFirstChild("DropOverlay")
                    if dOvr then dOvr:Destroy() end
                end

                -- Transparent overlay: blocks other UI + auto-closes on tap
                local overlay = Instance.new("TextButton")
                    overlay.Name = "DropOverlay"
                    overlay.BackgroundTransparency = 1
                    overlay.BorderSizePixel = 0
                    overlay.Size = UDim2.new(1, 0, 1, 0)
                    overlay.ZIndex = 9
                    overlay.Text = ""
                    overlay.AutoButtonColor = false
                    overlay.Parent = Main
                    csConn = overlay.Activated:Connect(function()
                        if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                    end)


            else
                local cfW3 = ContentFrame.AbsoluteSize.X
                local halfCF3 = math.floor(cfW3 / 2)
                local rightW3 = cfW3 - halfCF3 - 4
                ResetSearch()
                Limbo._activeDropdownClose = nil
                TweenService:Create(DropdownList, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, DropdownList.Size.Y.Offset),
                    Position = UDim2.new(0, 138 + halfCF3 + rightW3, 0, 8)
                }):Play()
                task.delay(0.18, function()
                    DropdownList.Visible = false
                    if csConn then csConn:Disconnect(); csConn = nil end
                    local dOvr = Main:FindFirstChild("DropOverlay")
                    if dOvr then dOvr:Destroy() end
                end)
            end
        end

        local function CreateOption(optionName)
            local Option = Instance.new("Frame")
            Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Option.BackgroundTransparency = 0.999
            Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Option.BorderSizePixel = 0
            Option.Size = UDim2.new(1, 0, 0, 30)
            Option.Name = "Option"
            Option.ZIndex = 12
            Option.Parent = ListScroll

            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 3)
            OptionCorner.Parent = Option

            local OptionButton = Instance.new("TextButton")
            OptionButton.Font = Enum.Font.GothamBold
            OptionButton.Text = ""
            OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.TextSize = 13
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.BackgroundTransparency = 0.999
            OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            OptionButton.BorderSizePixel = 0
            OptionButton.Size = UDim2.new(1, 0, 1, 0)
            OptionButton.Name = "OptionButton"
            OptionButton.ZIndex = 13
            OptionButton.Parent = Option

            local OptionText = Instance.new("TextLabel")
            OptionText.Font = Enum.Font.GothamBold
            OptionText.Text = optionName
            OptionText.TextSize = 13
            OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
            OptionText.TextXAlignment = Enum.TextXAlignment.Left
            OptionText.TextYAlignment = Enum.TextYAlignment.Top
            OptionText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionText.BackgroundTransparency = 0.999
            OptionText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            OptionText.BorderSizePixel = 0
            OptionText.Position = UDim2.new(0, 8, 0, 8)
            OptionText.Size = UDim2.new(1, -16, 0, 13)
            OptionText.Name = "OptionText"
            OptionText.ZIndex = 14
            OptionText.Parent = Option

            local ChooseFrame = Instance.new("Frame")
            ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
            ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
            ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.ZIndex = 15
            ChooseFrame.Parent = Option

            local ChooseStroke = Instance.new("UIStroke")
            ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            ChooseStroke.Thickness = 1.6
            ChooseStroke.Transparency = 0.999
            ChooseStroke.ZIndex = 16
            ChooseStroke.Parent = ChooseFrame

            local ChooseCorner = Instance.new("UICorner")
            ChooseCorner.Parent = ChooseFrame

            local optionId = HttpService:GenerateGUID(false)
            ConfigSystem.DropdownOptionFrames[optionId] = {
                Frame = Option,
                IsSelected = false
            }

            local function UpdateOptionVisual()
                local isSelected = false
                if dropdownData.Multi then
                    isSelected = table.find(dropdownData.Value, optionName) ~= nil
                else
                    isSelected = dropdownData.Value == optionName
                end

                ConfigSystem.DropdownOptionFrames[optionId].IsSelected = isSelected

                if isSelected then
                    TweenService:Create(ChooseStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                    TweenService:Create(ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 12)}):Play()
                    TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundTransparency = 0.935}):Play()
                    TweenService:Create(
                        OptionText,
                        TweenInfo.new(0.2),
                        {TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]}
                    ):Play()
                else
                    TweenService:Create(ChooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                    TweenService:Create(ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                    TweenService:Create(OptionText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play(

                    )
                end
            end

            OptionButton.Activated:Connect(
                function()
                    CircleClick(OptionButton, Mouse.X, Mouse.Y)

                    if dropdownData.Multi then
                        local index = table.find(dropdownData.Value, optionName)
                        if index then
                            table.remove(dropdownData.Value, index)
                        elseif #dropdownData.Value < dropdownData.MaxSelect then
                            table.insert(dropdownData.Value, optionName)
                        end
                        UpdateOptionVisual()
                    else
                        for _, child in ListScroll:GetChildren() do
                            if child:IsA("Frame") and child.Name == "Option" then
                                local childOptionText = child:FindFirstChild("OptionText")
                                if childOptionText and childOptionText.Text ~= optionName then
                                    local childChooseFrame = child:FindFirstChild("ChooseFrame")
                                    local childChooseStroke =
                                        childChooseFrame and childChooseFrame:FindFirstChild("UIStroke")

                                    if childChooseStroke then
                                        TweenService:Create(
                                            childChooseStroke,
                                            TweenInfo.new(0.2),
                                            {Transparency = 0.999}
                                        ):Play()
                                    end
                                    if childChooseFrame then
                                        TweenService:Create(
                                            childChooseFrame,
                                            TweenInfo.new(0.2),
                                            {Size = UDim2.new(0, 0, 0, 0)}
                                        ):Play()
                                    end
                                    TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play(

                                    )
                                    TweenService:Create(
                                        childOptionText,
                                        TweenInfo.new(0.2),
                                        {TextColor3 = Color3.fromRGB(230, 230, 230)}
                                    ):Play()

                                    for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                                        if data.Frame == child then
                                            data.IsSelected = false
                                        end
                                    end
                                end
                            end
                        end

                        dropdownData.Value = optionName
                        UpdateOptionVisual()
                    end

                    UpdateSelectedDisplay()

                    if callback then
                        callback(dropdownData.Value)
                    end
                end
            )

            UpdateOptionVisual()
            return Option
        end

        for _, option in ipairs(dropdownData.Options) do
            CreateOption(option)
        end

        UpdateListSize()
        UpdateSelectedDisplay()

        DropdownButton.Activated:Connect(
            function()
                CircleClick(DropdownButton, Mouse.X, Mouse.Y)
                ToggleDropdown()
            end
        )

        Dropdown.Destroying:Connect(
            function()
                for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                    if data.Frame and data.Frame:IsDescendantOf(DropdownList) then
                        ConfigSystem.DropdownOptionFrames[id] = nil
                    end
                end
                DropdownList:Destroy()
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local dropdownFunc = {
            Value = dropdownData.Value,
            _data = dropdownData,
            Options = dropdownData.Options,
            Type = "Dropdown",
            Id = elementId
        }

        function dropdownFunc:Set(value)
            if dropdownData.Multi then
                dropdownData.Value = value or {}
            else
                dropdownData.Value = value
            end
            UpdateSelectedDisplay()

            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    local optionName = child.OptionText.Text
                    local isSelected = false
                    if dropdownData.Multi then
                        isSelected = table.find(dropdownData.Value, optionName) ~= nil
                    else
                        isSelected = dropdownData.Value == optionName
                    end

                    local chooseFrame = child:FindFirstChild("ChooseFrame")
                    local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                    local optionText = child:FindFirstChild("OptionText")

                    if chooseFrame and chooseStroke and optionText then
                        if isSelected then
                            TweenService:Create(chooseStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                            TweenService:Create(chooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 12)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.935}):Play()
                            TweenService:Create(
                                optionText,
                                TweenInfo.new(0.2),
                                {TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]}
                            ):Play()
                        else
                            TweenService:Create(chooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                            TweenService:Create(chooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                            TweenService:Create(
                                optionText,
                                TweenInfo.new(0.2),
                                {TextColor3 = Color3.fromRGB(230, 230, 230)}
                            ):Play()
                        end
                    end
                end
            end
            if callback then pcall(callback, dropdownData.Value) end
        end

        function dropdownFunc:Refresh(newOptions, newValue)
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                if data.Frame and data.Frame:IsDescendantOf(ListScroll) then
                    ConfigSystem.DropdownOptionFrames[id] = nil
                end
            end

            dropdownData.Options = newOptions or {}
            dropdownData.Value = newValue or (dropdownData.Multi and {} or nil)

            for _, option in ipairs(dropdownData.Options) do
                CreateOption(option)
            end

            UpdateListSize()
            UpdateSelectedDisplay()
            dropdownFunc.Value = dropdownData.Value
            dropdownFunc.Options = dropdownData.Options
        end

        if elementId then
            AllElements[elementId] = dropdownFunc
        end

        return dropdownFunc
    end
    
    local function CreateSlider(
        tabContainer,
        title,
        content,
        minValue,
        maxValue,
        defaultValue,
        callback,
        elementId,
        showKnob)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        showKnob = showKnob ~= false

        local Slider = Instance.new("Frame")
        Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Slider.BackgroundTransparency = 0.935
        Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Slider.BorderSizePixel = 0
        Slider.Size = UDim2.new(1, 0, 0, 46)
        Slider.Name = "Slider"
        Slider.Parent = tabContainer

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 4)
        SliderCorner.Parent = Slider

        local SliderTitle = Instance.new("TextLabel")
        SliderTitle.Font = Enum.Font.GothamBold
        SliderTitle.Text = title
        SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        SliderTitle.TextSize = 14
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 0.999
        SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderTitle.BorderSizePixel = 0
        SliderTitle.Position = UDim2.new(0, 10, 0, 10)
        SliderTitle.Size = UDim2.new(1, -60, 0, 13)
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = Slider

        local SliderContent = Instance.new("TextLabel")
        SliderContent.Font = Enum.Font.GothamBold
        SliderContent.Text = content
        SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.TextSize = 13
        SliderContent.TextTransparency = 0.6
        SliderContent.TextXAlignment = Enum.TextXAlignment.Left
        SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
        SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.BackgroundTransparency = 0.999
        SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderContent.BorderSizePixel = 0
        SliderContent.Position = UDim2.new(0, 10, 0, 23)
        SliderContent.Size = UDim2.new(1, -60, 0, 12)
        SliderContent.Name = "SliderContent"
        SliderContent.Parent = Slider

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 80, math.huge)
        )

        SliderContent.Size = UDim2.new(1, -60, 0, textSize.Y)
        SliderContent.TextWrapped = true

        local ValueDisplay = Instance.new("TextLabel")
        ValueDisplay.Font = Enum.Font.GothamBold
        ValueDisplay.Text = tostring(defaultValue or minValue)
        ValueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.TextSize = 14
        ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        ValueDisplay.AnchorPoint = Vector2.new(1, 0)
        ValueDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.BackgroundTransparency = 0.999
        ValueDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ValueDisplay.BorderSizePixel = 0
        ValueDisplay.Position = UDim2.new(1, -10, 0, 10)
        ValueDisplay.Size = UDim2.new(0, 40, 0, 13)
        ValueDisplay.Name = "ValueDisplay"
        ValueDisplay.Parent = Slider

        Slider.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33 + 25))

        local SliderFrame = Instance.new("Frame")
        SliderFrame.AnchorPoint = Vector2.new(0, 0)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SliderFrame.BackgroundTransparency = 0.5
        SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(0, 10, 0, textSize.Y + 33)
        SliderFrame.Size = UDim2.new(1, -20, 0, 3)
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Slider

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 2)
        FrameCorner.Parent = SliderFrame

        local SliderFill = Instance.new("Frame")
        SliderFill.AnchorPoint = Vector2.new(0, 0.5)
        SliderFill.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        SliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFill.BorderSizePixel = 0
        SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
        SliderFill.Size = UDim2.new(0.5, 0, 0, 3)
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderFrame

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 2)
        FillCorner.Parent = SliderFill

        local SliderCircle = nil
        if showKnob then
            SliderCircle = Instance.new("Frame")
            SliderCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderCircle.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            SliderCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SliderCircle.BorderSizePixel = 0
            SliderCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderCircle.Size = UDim2.new(0, 12, 0, 12)
            SliderCircle.Name = "SliderCircle"
            SliderCircle.Parent = SliderFrame

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(0, 6)
            CircleCorner.Parent = SliderCircle

            local CircleStroke = Instance.new("UIStroke")
            CircleStroke.Color = Color3.fromRGB(255, 255, 255)
            CircleStroke.Thickness = 1
            CircleStroke.Parent = SliderCircle
        end

        table.insert(ConfigSystem.SliderElements, SliderFrame)

        local sliderData = {
            Min = minValue or 0,
            Max = maxValue or 100,
            Value = defaultValue or minValue or 0,
            Dragging = false,
            TouchInput = nil
        }

        local function Round(num, decimalPlaces)
            local mult = 10 ^ (decimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end

        local function SetValue(value, instant)
            value = math.clamp(value, sliderData.Min, sliderData.Max)
            sliderData.Value = Round(value, 0)

            ValueDisplay.Text = tostring(sliderData.Value)

            local percentage = (sliderData.Value - sliderData.Min) / (sliderData.Max - sliderData.Min)

            if instant then
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                if SliderCircle then
                    SliderCircle.Position = UDim2.new(percentage, 0, 0.5, 0)
                end
            else
                TweenService:Create(
                    SliderFill,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(percentage, 0, 1, 0)}
                ):Play()
                if SliderCircle then
                    TweenService:Create(
                        SliderCircle,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Position = UDim2.new(percentage, 0, 0.5, 0)}
                    ):Play()
                end
            end

            if callback then
                callback(sliderData.Value)
            end
        end

        local startValue = defaultValue or minValue or 0
        SetValue(startValue, true)

        local function UpdateSliderFromInput(input)
            local inputPos
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                inputPos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch then
                inputPos = input.Position
            else
                return
            end

            local sliderPos = SliderFrame.AbsolutePosition
            local sliderSize = SliderFrame.AbsoluteSize

            local percentage = math.clamp((inputPos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = sliderData.Min + (percentage * (sliderData.Max - sliderData.Min))

            SetValue(value)
        end

        SliderFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    sliderData.Dragging = true
                    sliderData.TouchInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                    UpdateSliderFromInput(input)
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if
                    sliderData.Dragging and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and
                                input == sliderData.TouchInput))
                 then
                    UpdateSliderFromInput(input)
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)
                if
                    (input.UserInputType == Enum.UserInputType.MouseButton1 and sliderData.Dragging) or
                        (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and
                            input == sliderData.TouchInput)
                 then
                    sliderData.Dragging = false
                    sliderData.TouchInput = nil
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local sliderFunc = {
            Value = sliderData.Value,
            _data = sliderData,
            _default = defaultValue,
            Type = "Slider",
            Id = elementId
        }

        function sliderFunc:Set(value)
            SetValue(value)
            sliderFunc.Value = sliderData.Value
        end

        if elementId then
            AllElements[elementId] = sliderFunc
        end

        return sliderFunc
    end
    
    local function CreateImageBox(tabContainer, title, content, imageId, size, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        
        local ImageBox = Instance.new("Frame")
        ImageBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBox.BackgroundTransparency = 0.935
        ImageBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBox.BorderSizePixel = 0
        ImageBox.Size = UDim2.new(1, 0, 0, 46)
        ImageBox.Name = "ImageBox"
        ImageBox.Parent = tabContainer

        local ImageBoxCorner = Instance.new("UICorner")
        ImageBoxCorner.CornerRadius = UDim.new(0, 4)
        ImageBoxCorner.Parent = ImageBox

        local ImageBoxTitle = Instance.new("TextLabel")
        ImageBoxTitle.Font = Enum.Font.GothamBold
        ImageBoxTitle.Text = title
        ImageBoxTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ImageBoxTitle.TextSize = 14
        ImageBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
        ImageBoxTitle.TextYAlignment = Enum.TextYAlignment.Top
        ImageBoxTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxTitle.BackgroundTransparency = 0.999
        ImageBoxTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBoxTitle.BorderSizePixel = 0
        ImageBoxTitle.Position = UDim2.new(0, 10, 0, 10)
        ImageBoxTitle.Size = UDim2.new(1, -20, 0, 13)
        ImageBoxTitle.Name = "ImageBoxTitle"
        ImageBoxTitle.Parent = ImageBox

        local ImageBoxContent = Instance.new("TextLabel")
        ImageBoxContent.Font = Enum.Font.GothamBold
        ImageBoxContent.Text = content
        ImageBoxContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxContent.TextSize = 13
        ImageBoxContent.TextTransparency = 0.6
        ImageBoxContent.TextXAlignment = Enum.TextXAlignment.Left
        ImageBoxContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ImageBoxContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageBoxContent.BackgroundTransparency = 0.999
        ImageBoxContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageBoxContent.BorderSizePixel = 0
        ImageBoxContent.Position = UDim2.new(0, 10, 0, 23)
        ImageBoxContent.Size = UDim2.new(1, -20, 0, 12)
        ImageBoxContent.Name = "ImageBoxContent"
        ImageBoxContent.Parent = ImageBox

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 40, math.huge)
        )
        ImageBoxContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        ImageBoxContent.TextWrapped = true

        local imageSize = size or UDim2.new(0, 100, 0, 100)
        local totalHeight = textSize.Y + 33 + imageSize.Y.Offset + 10

        ImageBox.Size = UDim2.new(1, 0, 0, math.max(46, totalHeight))

        local ImageContainer = Instance.new("Frame")
        ImageContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageContainer.BackgroundTransparency = 0.95
        ImageContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageContainer.BorderSizePixel = 0
        ImageContainer.Position = UDim2.new(0, 10, 0, textSize.Y + 33)
        ImageContainer.Size = imageSize
        ImageContainer.Name = "ImageContainer"
        ImageContainer.Parent = ImageBox

        local ContainerCorner = Instance.new("UICorner")
        ContainerCorner.CornerRadius = UDim.new(0, 4)
        ContainerCorner.Parent = ImageContainer

        local ImageDisplay = Instance.new("ImageLabel")
        ImageDisplay.Image = imageId or "rbxassetid://0"
        ImageDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageDisplay.BackgroundTransparency = 0.999
        ImageDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageDisplay.BorderSizePixel = 0
        ImageDisplay.Position = UDim2.new(0, 5, 0, 5)
        ImageDisplay.Size = UDim2.new(1, -10, 1, -10)
        ImageDisplay.Name = "ImageDisplay"
        ImageDisplay.Parent = ImageContainer

        local ImageButton = Instance.new("TextButton")
        ImageButton.Font = Enum.Font.SourceSans
        ImageButton.Text = ""
        ImageButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.TextSize = 14
        ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.BackgroundTransparency = 0.999
        ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageButton.BorderSizePixel = 0
        ImageButton.Size = UDim2.new(1, 0, 1, 0)
        ImageButton.Name = "ImageButton"
        ImageButton.Parent = ImageBox

        ImageButton.Activated:Connect(
            function()
                CircleClick(ImageButton, Mouse.X, Mouse.Y)
                if callback then
                    callback(imageId)
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local imageBoxFunc = {
            ImageId = imageId,
            Type = "ImageBox",
            Id = elementId
        }

        function imageBoxFunc:SetImage(newImageId)
            ImageDisplay.Image = newImageId
            imageBoxFunc.ImageId = newImageId
        end

        function imageBoxFunc:SetSize(newSize)
            ImageContainer.Size = newSize
            local newTotalHeight = textSize.Y + 33 + newSize.Y.Offset + 10
            ImageBox.Size = UDim2.new(1, 0, 0, math.max(46, newTotalHeight))
            UpdateContentSize()
        end

        if elementId then
            AllElements[elementId] = imageBoxFunc
        end

        return imageBoxFunc
    end

    local function CreateTextHeader(tabContainer, title)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end

        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.BorderSizePixel = 0
        header.Position = UDim2.new(0, 0, 0, 0)
        header.Size = UDim2.new(1, 0, 0, 28)
        header.Font = Enum.Font.GothamBold
        header.Text = title or ""
        header.TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        header.TextSize = 15
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextYAlignment = Enum.TextYAlignment.Center
        header.Name = "TextHeader"
        header.Parent = tabContainer

        local headerPadding = Instance.new("UIPadding")
        headerPadding.PaddingLeft = UDim.new(0, 10)
        headerPadding.Parent = header

        table.insert(
            ConfigSystem.ThemeElements, 
            {
                Update = function(color)
                    if header and header.Parent then
                        header.TextColor3 = color
                    end
                end
            }
        )

        return header
    end

    -- FIXED: Renamed from CreateSection to CreateDivider
    local function CreateDivider(tabContainer, title)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        
        local Divider = Instance.new("Frame")
        Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Divider.BackgroundTransparency = 0.935
        Divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Divider.BorderSizePixel = 0
        Divider.Size = UDim2.new(1, 0, 0, 40)
        Divider.Name = "Divider"
        Divider.Parent = tabContainer

        local DividerCorner = Instance.new("UICorner")
        DividerCorner.CornerRadius = UDim.new(0, 4)
        DividerCorner.Parent = Divider

        local DividerTitle = Instance.new("TextLabel")
        DividerTitle.Font = Enum.Font.GothamBold
        DividerTitle.Text = title
        DividerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        DividerTitle.TextSize = 14
        DividerTitle.TextXAlignment = Enum.TextXAlignment.Left
        DividerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DividerTitle.BackgroundTransparency = 0.999
        DividerTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DividerTitle.BorderSizePixel = 0
        DividerTitle.Position = UDim2.new(0, 10, 0, 0)
        DividerTitle.Size = UDim2.new(1, -20, 0, 40)
        DividerTitle.Name = "DividerTitle"
        DividerTitle.Parent = Divider

        local DividerLine = Instance.new("Frame")
        DividerLine.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        DividerLine.BackgroundTransparency = 0.5
        DividerLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DividerLine.BorderSizePixel = 0
        DividerLine.Position = UDim2.new(0, 10, 0, 35)
        DividerLine.Size = UDim2.new(1, -20, 0, 2)
        DividerLine.Name = "DividerLine"
        DividerLine.Parent = Divider

        table.insert(
            ConfigSystem.ThemeElements,
            {
                Update = function(color)
                    DividerLine.BackgroundColor3 = color
                end
            }
        )

        task.wait(0.1)
        UpdateContentSize()

        return Divider
    end

    local function CreateColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)

        local ColorPicker = Instance.new("Frame")
        ColorPicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPicker.BackgroundTransparency = 0.935
        ColorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPicker.BorderSizePixel = 0
        ColorPicker.Size = UDim2.new(1, 0, 0, 46)
        ColorPicker.Name = "ColorPicker"
        ColorPicker.Parent = tabContainer

        local ColorPickerCorner = Instance.new("UICorner")
        ColorPickerCorner.CornerRadius = UDim.new(0, 4)
        ColorPickerCorner.Parent = ColorPicker

        local ColorPickerTitle = Instance.new("TextLabel")
        ColorPickerTitle.Font = Enum.Font.GothamBold
        ColorPickerTitle.Text = title
        ColorPickerTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ColorPickerTitle.TextSize = 14
        ColorPickerTitle.TextXAlignment = Enum.TextXAlignment.Left
        ColorPickerTitle.TextYAlignment = Enum.TextYAlignment.Top
        ColorPickerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPickerTitle.BackgroundTransparency = 0.999
        ColorPickerTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerTitle.BorderSizePixel = 0
        ColorPickerTitle.Position = UDim2.new(0, 10, 0, 10)
        ColorPickerTitle.Size = UDim2.new(1, -100, 0, 13)
        ColorPickerTitle.Name = "ColorPickerTitle"
        ColorPickerTitle.Parent = ColorPicker

        local ColorPickerContent = Instance.new("TextLabel")
        ColorPickerContent.Font = Enum.Font.GothamBold
        ColorPickerContent.Text = content
        ColorPickerContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ColorPickerContent.TextSize = 13
        ColorPickerContent.TextTransparency = 0.6
        ColorPickerContent.TextXAlignment = Enum.TextXAlignment.Left
        ColorPickerContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ColorPickerContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorPickerContent.BackgroundTransparency = 0.999
        ColorPickerContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerContent.BorderSizePixel = 0
        ColorPickerContent.Position = UDim2.new(0, 10, 0, 23)
        ColorPickerContent.Size = UDim2.new(1, -100, 0, 12)
        ColorPickerContent.Name = "ColorPickerContent"
        ColorPickerContent.Parent = ColorPicker

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        ColorPickerContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ColorPickerContent.TextWrapped = true
        ColorPicker.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ColorPreview = Instance.new("Frame")
        ColorPreview.AnchorPoint = Vector2.new(1, 0.5)
        ColorPreview.BackgroundColor3 = defaultColor
        ColorPreview.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Position = UDim2.new(1, -15, 0.5, 0)
        ColorPreview.Size = UDim2.new(0, 30, 0, 30)
        ColorPreview.Name = "ColorPreview"
        ColorPreview.Parent = ColorPicker

        local PreviewCorner = Instance.new("UICorner")
        PreviewCorner.CornerRadius = UDim.new(0, 4)
        PreviewCorner.Parent = ColorPreview

        local PreviewStroke = Instance.new("UIStroke")
        PreviewStroke.Color = Color3.fromRGB(255, 255, 255)
        PreviewStroke.Thickness = 1
        PreviewStroke.Transparency = 0.5
        PreviewStroke.Parent = ColorPreview

        local ColorPickerButton = Instance.new("TextButton")
        ColorPickerButton.Font = Enum.Font.SourceSans
        ColorPickerButton.Text = ""
        ColorPickerButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerButton.TextSize = 14
        ColorPickerButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerButton.BackgroundTransparency = 0.999
        ColorPickerButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerButton.BorderSizePixel = 0
        ColorPickerButton.Size = UDim2.new(1, 0, 1, 0)
        ColorPickerButton.Name = "ColorPickerButton"
        ColorPickerButton.Parent = ColorPicker

        local ColorPickerFrame = Instance.new("Frame")
        ColorPickerFrame.AnchorPoint = Vector2.new(1, 0)
        ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ColorPickerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ColorPickerFrame.BorderSizePixel = 0
        ColorPickerFrame.Position = UDim2.new(1, -12, 0, 35)
        ColorPickerFrame.Size = UDim2.new(0, 200, 0, 0)
        ColorPickerFrame.Name = "ColorPickerFrame"
        ColorPickerFrame.Visible = false
        ColorPickerFrame.ClipsDescendants = true
        ColorPickerFrame.ZIndex = 10
        ColorPickerFrame.Parent = ScreenGui

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = ColorPickerFrame

        local FrameStroke = Instance.new("UIStroke")
        FrameStroke.Color = Color3.fromRGB(255, 255, 255)
        FrameStroke.Thickness = 2.5
        FrameStroke.Transparency = 0.8
        FrameStroke.Parent = ColorPickerFrame

        local HueFrame = Instance.new("Frame")
        HueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueFrame.BackgroundTransparency = 0.999
        HueFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        HueFrame.BorderSizePixel = 0
        HueFrame.Position = UDim2.new(0, 10, 0, 10)
        HueFrame.Size = UDim2.new(0, 180, 0, 100)
        HueFrame.Name = "HueFrame"
        HueFrame.ZIndex = 11
        HueFrame.Parent = ColorPickerFrame

        local HueGradient = Instance.new("UIGradient")
        HueGradient.Color =
            ColorSequence.new(
            {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }
        )
        HueGradient.Parent = HueFrame

        local HueCorner = Instance.new("UICorner")
        HueCorner.CornerRadius = UDim.new(0, 4)
        HueCorner.Parent = HueFrame

        local SatValFrame = Instance.new("Frame")
        SatValFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SatValFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SatValFrame.BorderSizePixel = 0
        SatValFrame.Position = UDim2.new(0, 10, 0, 120)
        SatValFrame.Size = UDim2.new(0, 180, 0, 80)
        SatValFrame.Name = "SatValFrame"
        SatValFrame.ZIndex = 11
        SatValFrame.Parent = ColorPickerFrame

        local SatValGradient = Instance.new("UIGradient")
        SatValGradient.Color =
            ColorSequence.new(
            {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }
        )
        SatValGradient.Parent = SatValFrame

        local SatValCorner = Instance.new("UICorner")
        SatValCorner.CornerRadius = UDim.new(0, 4)
        SatValCorner.Parent = SatValFrame

        local HueSlider = Instance.new("Frame")
        HueSlider.AnchorPoint = Vector2.new(0.5, 0.5)
        HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueSlider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        HueSlider.BorderSizePixel = 0
        HueSlider.Position = UDim2.new(0, 0, 0.5, 0)
        HueSlider.Size = UDim2.new(0, 4, 1, 0)
        HueSlider.Name = "HueSlider"
        HueSlider.ZIndex = 12
        HueSlider.Parent = HueFrame

        local HueSliderCorner = Instance.new("UICorner")
        HueSliderCorner.CornerRadius = UDim.new(0, 2)
        HueSliderCorner.Parent = HueSlider

        local HueSliderStroke = Instance.new("UIStroke")
        HueSliderStroke.Color = Color3.fromRGB(0, 0, 0)
        HueSliderStroke.Thickness = 1
        HueSliderStroke.Parent = HueSlider

        local SatValCursor = Instance.new("Frame")
        SatValCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        SatValCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SatValCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SatValCursor.BorderSizePixel = 0
        SatValCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        SatValCursor.Size = UDim2.new(0, 8, 0, 8)
        SatValCursor.Name = "SatValCursor"
        SatValCursor.ZIndex = 12
        SatValCursor.Parent = SatValFrame

        local SatValCursorCorner = Instance.new("UICorner")
        SatValCursorCorner.CornerRadius = UDim.new(0, 4)
        SatValCursorCorner.Parent = SatValCursor

        local SatValCursorStroke = Instance.new("UIStroke")
        SatValCursorStroke.Color = Color3.fromRGB(0, 0, 0)
        SatValCursorStroke.Thickness = 1
        SatValCursorStroke.Parent = SatValCursor

        local ColorPickerData = {
            Hue = 0,
            Sat = 1,
            Val = 1,
            DraggingHue = false,
            DraggingSatVal = false,
            Open = false
        }

        local function Color3ToHSV(color)
            local r, g, b = color.R, color.G, color.B
            local max = math.max(r, g, b)
            local min = math.min(r, g, b)
            local v = max
            local s = (max == 0) and 0 or (max - min) / max
            local h = 0

            if max ~= min then
                local d = max - min
                if max == r then
                    h = (g - b) / d + (g < b and 6 or 0)
                elseif max == g then
                    h = (b - r) / d + 2
                elseif max == b then
                    h = (r - g) / d + 4
                end
                h = h / 6
            end

            return h, s, v
        end

        local function HSVToColor3(h, s, v)
            local r, g, b
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)

            i = i % 6

            if i == 0 then
                r, g, b = v, t, p
            elseif i == 1 then
                r, g, b = q, v, p
            elseif i == 2 then
                r, g, b = p, v, t
            elseif i == 3 then
                r, g, b = p, q, v
            elseif i == 4 then
                r, g, b = t, p, v
            elseif i == 5 then
                r, g, b = v, p, q
            end

            return Color3.new(r, g, b)
        end

        local function UpdateColorFromHSV()
            local color = HSVToColor3(ColorPickerData.Hue, ColorPickerData.Sat, ColorPickerData.Val)
            ColorPreview.BackgroundColor3 = color
            SatValGradient.Color =
                ColorSequence.new(
                {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, HSVToColor3(ColorPickerData.Hue, 1, 1))
                }
            )

            if callback then
                callback(color)
            end
        end

        local function SetColor(color)
            local h, s, v = Color3ToHSV(color)
            ColorPickerData.Hue = h
            ColorPickerData.Sat = s
            ColorPickerData.Val = v

            HueSlider.Position = UDim2.new(h, 0, 0.5, 0)
            SatValCursor.Position = UDim2.new(s, 0, 1 - v, 0)

            UpdateColorFromHSV()
        end

        SetColor(defaultColor)

        local function ToggleColorPicker()
            ColorPickerData.Open = not ColorPickerData.Open
            if ColorPickerData.Open then
                local pickerAbsPos = ColorPicker.AbsolutePosition
                local pickerAbsSize = ColorPicker.AbsoluteSize
                ColorPickerFrame.Position =
                    UDim2.new(0, pickerAbsPos.X + pickerAbsSize.X - 212, 0, pickerAbsPos.Y + pickerAbsSize.Y + 5)

                ColorPickerFrame.Visible = true
                TweenService:Create(ColorPickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 210)}):Play()
            else
                TweenService:Create(ColorPickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 0)}):Play()
                task.wait(0.5)
                ColorPickerFrame.Visible = false
            end
        end

        HueFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    ColorPickerData.DraggingHue = true
                    local pos =
                        math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
                    ColorPickerData.Hue = pos
                    HueSlider.Position = UDim2.new(pos, 0, 0.5, 0)
                    UpdateColorFromHSV()
                end
            end
        )

        SatValFrame.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    ColorPickerData.DraggingSatVal = true
                    local sat =
                        math.clamp(
                        (input.Position.X - SatValFrame.AbsolutePosition.X) / SatValFrame.AbsoluteSize.X,
                        0,
                        1
                    )
                    local val =
                        1 -
                        math.clamp(
                            (input.Position.Y - SatValFrame.AbsolutePosition.Y) / SatValFrame.AbsoluteSize.Y,
                            0,
                            1
                        )
                    ColorPickerData.Sat = sat
                    ColorPickerData.Val = val
                    SatValCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    UpdateColorFromHSV()
                end
            end
        )

        UserInputService.InputChanged:Connect(
            function(input)
                if
                    ColorPickerData.DraggingHue and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            input.UserInputType == Enum.UserInputType.Touch)
                 then
                    local pos =
                        math.clamp((input.Position.X - HueFrame.AbsolutePosition.X) / HueFrame.AbsoluteSize.X, 0, 1)
                    ColorPickerData.Hue = pos
                    HueSlider.Position = UDim2.new(pos, 0, 0.5, 0)
                    UpdateColorFromHSV()
                elseif
                    ColorPickerData.DraggingSatVal and
                        (input.UserInputType == Enum.UserInputType.MouseMovement or
                            input.UserInputType == Enum.UserInputType.Touch)
                 then
                    local sat =
                        math.clamp(
                        (input.Position.X - SatValFrame.AbsolutePosition.X) / SatValFrame.AbsoluteSize.X,
                        0,
                        1
                    )
                    local val =
                        1 -
                        math.clamp(
                            (input.Position.Y - SatValFrame.AbsolutePosition.Y) / SatValFrame.AbsoluteSize.Y,
                            0,
                            1
                        )
                    ColorPickerData.Sat = sat
                    ColorPickerData.Val = val
                    SatValCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                    UpdateColorFromHSV()
                end
            end
        )

        UserInputService.InputEnded:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    ColorPickerData.DraggingHue = false
                    ColorPickerData.DraggingSatVal = false
                end
            end
        )

        ColorPickerButton.Activated:Connect(
            function()
                CircleClick(ColorPickerButton, Mouse.X, Mouse.Y)
                ToggleColorPicker()
            end
        )

        local colorPickerConnection
        colorPickerConnection =
            UserInputService.InputBegan:Connect(
            function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1 or
                        input.UserInputType == Enum.UserInputType.Touch
                 then
                    if ColorPickerData.Open and ColorPickerFrame.Visible then
                        local mousePos = input.Position
                        local pickerPos = ColorPickerFrame.AbsolutePosition
                        local pickerSize = ColorPickerFrame.AbsoluteSize
                        local previewPos = ColorPreview.AbsolutePosition
                        local previewSize = ColorPreview.AbsoluteSize

                        if
                            not (mousePos.X >= pickerPos.X and mousePos.X <= pickerPos.X + pickerSize.X and
                                mousePos.Y >= pickerPos.Y and
                                mousePos.Y <= pickerPos.Y + pickerSize.Y) and
                                not (mousePos.X >= previewPos.X and mousePos.X <= previewPos.X + previewSize.X and
                                    mousePos.Y >= previewPos.Y and
                                    mousePos.Y <= previewPos.Y + previewSize.Y)
                         then
                            ToggleColorPicker()
                        end
                    end
                end
            end
        )
        ColorPicker.Destroying:Connect(
            function()
                if colorPickerConnection then
                    colorPickerConnection:Disconnect()
                end
                ColorPickerFrame:Destroy()
            end
        )
        task.wait(0.1)
        UpdateContentSize()

        local colorPickerFunc = {
            Value = defaultColor,
            Type = "ColorPicker",
            Id = elementId
        }

        function colorPickerFunc:Set(color)
            SetColor(color)
            colorPickerFunc.Value = color
        end

        if elementId then
            AllElements[elementId] = colorPickerFunc
        end

        return colorPickerFunc
    end

    local function CreateKeybind(tabContainer, title, content, defaultKey, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then
            return
        end
        local Keybind = Instance.new("Frame")
        Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Keybind.BackgroundTransparency = 0.935
        Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Keybind.BorderSizePixel = 0
        Keybind.Size = UDim2.new(1, 0, 0, 46)
        Keybind.Name = "Keybind"
        Keybind.Parent = tabContainer

        local KeybindCorner = Instance.new("UICorner")
        KeybindCorner.CornerRadius = UDim.new(0, 4)
        KeybindCorner.Parent = Keybind

        local KeybindTitle = Instance.new("TextLabel")
        KeybindTitle.Font = Enum.Font.GothamBold
        KeybindTitle.Text = title
        KeybindTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        KeybindTitle.TextSize = 14
        KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
        KeybindTitle.TextYAlignment = Enum.TextYAlignment.Top
        KeybindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindTitle.BackgroundTransparency = 0.999
        KeybindTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindTitle.BorderSizePixel = 0
        KeybindTitle.Position = UDim2.new(0, 10, 0, 10)
        KeybindTitle.Size = UDim2.new(1, -100, 0, 13)
        KeybindTitle.Name = "KeybindTitle"
        KeybindTitle.Parent = Keybind

        local KeybindContent = Instance.new("TextLabel")
        KeybindContent.Font = Enum.Font.GothamBold
        KeybindContent.Text = content
        KeybindContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindContent.TextSize = 13
        KeybindContent.TextTransparency = 0.6
        KeybindContent.TextXAlignment = Enum.TextXAlignment.Left
        KeybindContent.TextYAlignment = Enum.TextYAlignment.Bottom
        KeybindContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindContent.BackgroundTransparency = 0.999
        KeybindContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindContent.BorderSizePixel = 0
        KeybindContent.Position = UDim2.new(0, 10, 0, 23)
        KeybindContent.Size = UDim2.new(1, -100, 0, 12)
        KeybindContent.Name = "KeybindContent"
        KeybindContent.Parent = Keybind

        local textSize =
            TextService:GetTextSize(
            content,
            12,
            Enum.Font.GothamBold,
            Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge)
        )

        KeybindContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        KeybindContent.TextWrapped = true
        Keybind.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local KeybindFrame = Instance.new("Frame")
        KeybindFrame.AnchorPoint = Vector2.new(1, 0.5)
        KeybindFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindFrame.BackgroundTransparency = 0.95
        KeybindFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindFrame.BorderSizePixel = 0
        KeybindFrame.ClipsDescendants = true
        KeybindFrame.Position = UDim2.new(1, -7, 0.5, 0)
        KeybindFrame.Size = UDim2.new(0, 80, 0, 30)
        KeybindFrame.Name = "KeybindFrame"
        KeybindFrame.Parent = Keybind

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = KeybindFrame

        local KeybindText = Instance.new("TextLabel")
        KeybindText.Font = Enum.Font.GothamBold
        KeybindText.Text = defaultKey and defaultKey.Name or "None"
        KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindText.TextSize = 13
        KeybindText.TextTransparency = 0.6
        KeybindText.TextXAlignment = Enum.TextXAlignment.Center
        KeybindText.TextYAlignment = Enum.TextYAlignment.Center
        KeybindText.AnchorPoint = Vector2.new(0.5, 0.5)
        KeybindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        KeybindText.BackgroundTransparency = 0.999
        KeybindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindText.BorderSizePixel = 0
        KeybindText.Position = UDim2.new(0.5, 0, 0.5, 0)
        KeybindText.Size = UDim2.new(1, -10, 1, -8)
        KeybindText.Name = "KeybindText"
        KeybindText.Parent = KeybindFrame

        local KeybindButton = Instance.new("TextButton")
        KeybindButton.Font = Enum.Font.SourceSans
        KeybindButton.Text = ""
        KeybindButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.TextSize = 14
        KeybindButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.BackgroundTransparency = 0.999
        KeybindButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        KeybindButton.BorderSizePixel = 0
        KeybindButton.Size = UDim2.new(1, 0, 1, 0)
        KeybindButton.Name = "KeybindButton"
        KeybindButton.Parent = Keybind

        local keybindData = {
            Key = defaultKey,
            Listening = false,
            Connection = nil
        }

        local function SetKey(key)
            keybindData.Key = key
            KeybindText.Text = key and key.Name or "None"

            if keybindData.Connection then
                keybindData.Connection:Disconnect()
                keybindData.Connection = nil
            end

            if key then
                keybindData.Connection =
                    UserInputService.InputBegan:Connect(
                    function(input, gameProcessed)
                        if not gameProcessed and input.KeyCode == key then
                            if callback then
                                callback(key)
                            end
                        end
                    end
                )
            end
        end

        KeybindButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(KeybindButton, Mouse.X, Mouse.Y)

                if keybindData.Listening then
                    return
                end
                keybindData.Listening = true

                KeybindText.Text = "..."
                KeybindText.TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]

                local listeningConnection
                listeningConnection =
                    UserInputService.InputBegan:Connect(
                    function(input, gameProcessed)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                keybindData.Listening = false
                                KeybindText.Text = keybindData.Key and keybindData.Key.Name or "None"
                                KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)
                                if listeningConnection then
                                    listeningConnection:Disconnect()
                                end
                                return
                            end

                            keybindData.Listening = false
                            SetKey(input.KeyCode)
                            KeybindText.TextColor3 = Color3.fromRGB(255, 255, 255)

                            if listeningConnection then
                                listeningConnection:Disconnect()
                            end
                        end
                    end
                )
            end
        )

        if defaultKey then
            SetKey(defaultKey)
        end

        Keybind.Destroying:Connect(
            function()
                if keybindData.Connection then
                    keybindData.Connection:Disconnect()
                end
            end
        )

        task.wait(0.1)
        UpdateContentSize()

        local keybindFunc = {
            Value = defaultKey,
            Type = "Keybind",
            Id = elementId
        }

        function keybindFunc:Set(key)
            SetKey(key)
            keybindFunc.Value = key
        end

        if elementId then
            AllElements[elementId] = keybindFunc
        end

        return keybindFunc
    end
    
    local function CreateButtonGrid(tabContainer, btn1Config, btn2Config)
        if not tabContainer or not tabContainer:IsA("Frame") then return end

        local GridFrame = Instance.new("Frame")
        GridFrame.BackgroundTransparency = 1
        GridFrame.Size = UDim2.new(1, 0, 0, 36)
        GridFrame.BorderSizePixel = 0
        GridFrame.Name = "ButtonGrid"
        GridFrame.Parent = tabContainer

        local GridLayout = Instance.new("UIListLayout")
        GridLayout.FillDirection = Enum.FillDirection.Horizontal
        GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
        GridLayout.Padding = UDim.new(0, 6)
        GridLayout.Parent = GridFrame

        local function makeHalfBtn(cfg, order)
            local Btn = Instance.new("TextButton")
            Btn.Font = Enum.Font.GothamBold
            Btn.Text = cfg.Title or "Button"
            Btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            Btn.TextSize = 12
            Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Btn.BackgroundTransparency = 0.92
            Btn.BorderSizePixel = 0
            Btn.Size = UDim2.new(0.5, -3, 1, 0)
            Btn.LayoutOrder = order
            Btn.AutoButtonColor = true
            Btn.Name = "GridBtn"
            Btn.Parent = GridFrame

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Btn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(80, 80, 80)
            BtnStroke.Thickness = 1
            BtnStroke.Transparency = 0.6
            BtnStroke.Parent = Btn

            if cfg.Callback then
                Btn.Activated:Connect(function()
                    if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                    CircleClick(Btn, Mouse.X, Mouse.Y)
                    cfg.Callback()
                end)
            end
            return Btn
        end

        makeHalfBtn(btn1Config or {}, 1)
        makeHalfBtn(btn2Config or {}, 2)

        task.wait(0.1)
        UpdateContentSize()
    end

    local function CreateCollapsible(tabContainer, title, defaultOpen)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        defaultOpen = defaultOpen == true

        local SectionFrame = Instance.new("Frame")
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Size = UDim2.new(1, 0, 0, 34)
        SectionFrame.BorderSizePixel = 0
        SectionFrame.ClipsDescendants = true
        SectionFrame.Name = "Collapsible"
        SectionFrame.Parent = tabContainer

        local HeaderBtn = Instance.new("TextButton")
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
        HeaderBtn.Font = Enum.Font.GothamBold
        HeaderBtn.Text = "  " .. (title or "Section")
        HeaderBtn.TextColor3 = Color3.fromRGB(170, 170, 185)
        HeaderBtn.TextSize = 14
        HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left
        HeaderBtn.BorderSizePixel = 0
        HeaderBtn.Name = "HeaderBtn"
        HeaderBtn.Parent = SectionFrame

        local SectionArrow = Instance.new("ImageLabel")
        SectionArrow.BackgroundTransparency = 1
        SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
        SectionArrow.Position = UDim2.new(1, -8, 0.5, 0)
        SectionArrow.Size = UDim2.new(0, 25, 0, 25)
        SectionArrow.Image = "rbxassetid://16851841101"
        SectionArrow.ImageTransparency = 0.3
        SectionArrow.Rotation = defaultOpen and 0 or -90
        SectionArrow.Name = "SectionArrow"
        SectionArrow.Parent = HeaderBtn

        local InnerContainer = Instance.new("Frame")
        InnerContainer.BackgroundTransparency = 1
        InnerContainer.Position = UDim2.new(0, 0, 0, 34)
        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
        InnerContainer.BorderSizePixel = 0
        InnerContainer.ClipsDescendants = true
        InnerContainer.Name = "InnerContainer"
        InnerContainer.Parent = SectionFrame

        local InnerLayout = Instance.new("UIListLayout")
        InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        InnerLayout.Padding = UDim.new(0, 5)
        InnerLayout.Parent = InnerContainer



        local isOpen = defaultOpen

        local function updateSize()
            

            local contentH = InnerLayout.AbsoluteContentSize.Y + 8
            if isOpen then
                InnerContainer.Size = UDim2.new(1, 0, 0, contentH)
                SectionFrame.Size  = UDim2.new(1, 0, 0, 34 + contentH)
                TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0}):Play()
            else
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                SectionFrame.Size  = UDim2.new(1, 0, 0, 34)
                TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = -90}):Play()
            end
            task.wait(0.01)
            UpdateContentSize()
        end

        InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if isOpen then updateSize() end
        end)

        HeaderBtn.Activated:Connect(function()
            if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
            isOpen = not isOpen
            updateSize()
        end)



        -- register in SearchSections for live search
        local rawName = (tabContainer and tabContainer.Name) or ""
        local tabName = rawName ~= "" and rawName:gsub("Content$", "") or nil
        if tabName and title and title ~= "" then
            local secTitle = (title or ""):gsub("^%s+", "")
            table.insert(SearchSections, {
                title   = secTitle,
                tabName = tabName,
                secFrame = SectionFrame,
                openFn  = function()
                    if not isOpen then
                        isOpen = true
                        updateSize()
                    end
                end,
            })
        end

        updateSize()
        return InnerContainer
    end

    local function CreateTabButton(tabName, iconId, isConfigTab)
        TabCount = TabCount + 1
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = 0.999
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.LayoutOrder = isConfigTab and 999 or TabCount
        Tab.Name = "Tab"
        Tab.Parent = TabScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = Tab

        local TabButton = Instance.new("TextButton")
        TabButton.ZIndex = 10
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.999
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local TabNameLabel = Instance.new("TextLabel")
        TabNameLabel.Font = Enum.Font.GothamBold
        TabNameLabel.Text = tabName
        TabNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.TextSize = 13
        TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.BackgroundTransparency = 0.999
        TabNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabNameLabel.BorderSizePixel = 0
        TabNameLabel.Size = UDim2.new(1, 0, 1, 0)
        TabNameLabel.Position = UDim2.new(0, iconId and iconId ~= "" and 30 or 10, 0, 0)
        TabNameLabel.Name = "TabName"
        TabNameLabel.Parent = Tab

        local resolvedTabIcon = ResolveIcon(iconId)
        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = resolvedTabIcon or ""
        FeatureImg.BackgroundTransparency = 1
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Visible = resolvedTabIcon ~= nil and resolvedTabIcon ~= ""
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab



        local ChooseFrame = Instance.new("Frame")
        ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ChooseFrame.BorderSizePixel = 0
        ChooseFrame.Position = UDim2.new(0, 0, 0, 9)
        ChooseFrame.Size = UDim2.new(0, 3, 0, 12)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Tab
        ChooseFrame.Visible = false

        local ChooseStroke = Instance.new("UIStroke")
        ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseStroke.Thickness = 1.6
        ChooseStroke.Parent = ChooseFrame

        local ChooseCorner = Instance.new("UICorner")
        ChooseCorner.Parent = ChooseFrame

        table.insert(ConfigSystem.TabElements, Tab)

        local TabContentContainer = Instance.new("Frame")
        TabContentContainer.BackgroundTransparency = 1
        TabContentContainer.Size = UDim2.new(1, 0, 0, 0)
        TabContentContainer.Visible = false
        TabContentContainer.LayoutOrder = isConfigTab and 999 or TabCount
        TabContentContainer.Name = tabName .. "Content"
        TabContentContainer.Parent = ContentScroll

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = TabContentContainer

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
            function()
                TabContentContainer.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
                ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
            end
        )

        TabContents[tabName] = TabContentContainer
        TabContentContainer:SetAttribute("LimboTabName", tabName)

        local function SwitchToTab()
            for name, container in pairs(TabContents) do
                container.Visible = false
            end

            for _, tabFrame in TabScroll:GetChildren() do
                if tabFrame:IsA("Frame") and tabFrame.Name == "Tab" then
                    local chooseFrame = tabFrame:FindFirstChild("ChooseFrame")
                    if chooseFrame then
                        chooseFrame.Visible = false
                    end
                    tabFrame.BackgroundTransparency = 0.999
                end
            end

            TabContentContainer.Visible = true
            ChooseFrame.Visible = true
            Tab.BackgroundTransparency = 0.92
            CurrentTab = tabName
            UpdateContentSize()
        end

        TabSwitchFns[tabName] = SwitchToTab

        TabButton.Activated:Connect(
            function()
                if Limbo._activeDropdownClose then Limbo._activeDropdownClose() end
                CircleClick(TabButton, Mouse.X, Mouse.Y)
                SwitchToTab()
            end
        )

        return TabContentContainer, SwitchToTab
    end
    
    local ConfigTabContainer, SwitchToConfigTab = CreateTabButton("Configuration", "rbxassetid://140704441124047", true)
    
    -- Config tab setup
    local CurrentConfigName = ""
    local SelectedConfigName = ""
    local AutoloadFile = ConfigFolder .. "/Autoload.txt"
    local CfgSection = CreateCollapsible(ConfigTabContainer, "Configuration", true)

    -- Status header frame with gear icon + two-line status
    local CfgHeaderFrame = Instance.new("Frame", CfgSection)
    CfgHeaderFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    CfgHeaderFrame.BackgroundTransparency = 0.935
    CfgHeaderFrame.BorderSizePixel = 0
    CfgHeaderFrame.Size = UDim2.new(1, 0, 0, 56)
    CfgHeaderFrame.Name = "CfgHeader"
    Instance.new("UICorner", CfgHeaderFrame).CornerRadius = UDim.new(0, 4)

    local CfgGearIcon = Instance.new("ImageLabel", CfgHeaderFrame)
    CfgGearIcon.Image = "rbxassetid://112919034802026"
    CfgGearIcon.BackgroundTransparency = 1
    CfgGearIcon.Position = UDim2.new(0, 8, 0.5, 0)
    CfgGearIcon.AnchorPoint = Vector2.new(0, 0.5)
    CfgGearIcon.Size = UDim2.new(0, 18, 0, 18)
    CfgGearIcon.ZIndex = 2

    local CfgTitle = Instance.new("TextLabel", CfgHeaderFrame)
    CfgTitle.Font = Enum.Font.GothamBold
    CfgTitle.Text = "Config Manager"
    CfgTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
    CfgTitle.TextSize = 14
    CfgTitle.TextXAlignment = Enum.TextXAlignment.Left
    CfgTitle.BackgroundTransparency = 1
    CfgTitle.BorderSizePixel = 0
    CfgTitle.Position = UDim2.new(0, 32, 0, 13)
    CfgTitle.Size = UDim2.new(1, -36, 0, 14)
    CfgTitle.ZIndex = 2

    local CfgStatusLabel = Instance.new("TextLabel", CfgHeaderFrame)
    CfgStatusLabel.Font = Enum.Font.GothamBold
    CfgStatusLabel.Text = "Current: None  |  Autoload: None"
    CfgStatusLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    CfgStatusLabel.TextSize = 12
    CfgStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    CfgStatusLabel.TextWrapped = true
    CfgStatusLabel.BackgroundTransparency = 1
    CfgStatusLabel.BorderSizePixel = 0
    CfgStatusLabel.Position = UDim2.new(0, 32, 0, 29)
    CfgStatusLabel.Size = UDim2.new(1, -36, 0, 24)
    CfgStatusLabel.ZIndex = 2

    local function updateCfgStatus()
        local cur = CurrentConfigName ~= "" and CurrentConfigName or "None"
        local al = "None"
        pcall(function()
            if isfile(AutoloadFile) then
                local v = readfile(AutoloadFile)
                if v and v ~= "" then al = v end
            end
        end)
        CfgStatusLabel.Text = "Current: " .. cur .. "  |  Autoload: " .. al
    end
    updateCfgStatus()



    local ConfigNameInput =
        CreateInput(
        CfgSection,
        "Config Name",
        "",
        "Write your input here...",
        function(value)
            CurrentConfigName = value
        end,
        "ConfigName"
    )

    local SelectConfigDropdown = CreateDropdown(
        CfgSection,
        "Select Config",
        "Choose from saved configs",
        ConfigSystem:GetConfigList(),
        false,
        nil,
        function(value)
            if value and value ~= "" then
                SelectedConfigName = value
                CurrentConfigName = value
                updateCfgStatus()
            end
        end,
        "SelectConfigDropdown"
    )

    local function doSaveConfig()
        local targetName = CurrentConfigName ~= "" and CurrentConfigName or SelectedConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Enter or select a config name first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local configData = {}
        for id, element in pairs(AllElements) do
            local val = nil
            if element.Type == "Toggle" then
                local live = element._live and element._live() or element.Value
                val = live
            elseif element.Type == "Slider" then
                local live = element._data and element._data.Value or element.Value
                local def = element._default
                if def == nil or live ~= def then val = live end
            elseif element.Type == "Dropdown" then
                local live = element._data and element._data.Value or element.Value
                if element._data and element._data.Multi then
                    if type(live) == "table" and #live > 0 then val = live end
                else
                    if live and live ~= "" and live ~= "Select Option" then val = live end
                end
            elseif element.Type == "Input" then
                if element.Value and element.Value ~= "" then val = element.Value end
            elseif element.Type == "ColorPicker" then
                if element.Value then val = {element.Value.R, element.Value.G, element.Value.B} end
            elseif element.Type == "Keybind" then
                if element.Value then val = element.Value.Name end
            end
            if val ~= nil then
                configData[id] = val
            end
        end
        local notifyData = ConfigSystem:SaveConfig(targetName, configData)
        MakeNotify(notifyData)
        CurrentConfigName = targetName
        updateCfgStatus()
        local configList = ConfigSystem:GetConfigList()
        SelectConfigDropdown:Refresh(configList)
    end

    local function doLoadConfig()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local _, configData = ConfigSystem:LoadConfig(targetName)
        if configData then
            for id, val in pairs(configData) do
                pcall(function()
                    if AllElements[id] then
                        if AllElements[id].Type == "Toggle" and val == false then
                            return
                        end
                        if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                            AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                        elseif AllElements[id].Type == "Keybind" and val then
                            AllElements[id]:Set(Enum.KeyCode[val])
                        else
                            AllElements[id]:Set(val)
                        end
                    end
                end)
            end
        end
        CurrentConfigName = targetName
        updateCfgStatus()
        MakeNotify({ Title = "Config", Description = "Loaded", Content = "\"" .. targetName .. "\" loaded!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
    end

    local function doDeleteConfig()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        local notifyData = ConfigSystem:DeleteConfig(targetName)
        MakeNotify(notifyData)
        SelectedConfigName = ""
        CurrentConfigName = ""
        updateCfgStatus()
        local configList = ConfigSystem:GetConfigList()
        SelectConfigDropdown:Refresh(configList)
    end

    local function doSetAutoload()
        local targetName = SelectedConfigName ~= "" and SelectedConfigName or CurrentConfigName
        if not targetName or targetName == "" then
            MakeNotify({ Title = "Config", Description = "Error", Content = "Select a config first!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
            return
        end
        pcall(function()
            if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
            writefile(AutoloadFile, targetName)
        end)
        MakeNotify({ Title = "Config", Description = "Autoload Set", Content = "Autoload -> \"" .. targetName .. "\"", Color = Color3.fromRGB(150,150,170), Delay = 3 })
        updateCfgStatus()
    end

    local function doClearAutoload()
        pcall(function()
            if isfile(AutoloadFile) then writefile(AutoloadFile, "") end
        end)
        MakeNotify({ Title = "Config", Description = "Cleared", Content = "Autoload cleared.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
        updateCfgStatus()
    end

    CreateButtonGrid(CfgSection,
        { Title = "Save Config", Callback = doSaveConfig },
        { Title = "Load Config", Callback = doLoadConfig }
    )

    CreateButtonGrid(CfgSection,
        { Title = "Delete Config", Callback = doDeleteConfig },
        { Title = "Set Autoload",  Callback = doSetAutoload }
    )

    CreateButtonGrid(CfgSection,
        { Title = "Refresh List", Callback = function()
            local configList = ConfigSystem:GetConfigList()
            SelectConfigDropdown:Refresh(configList)
            MakeNotify({ Title = "Config", Description = "Refreshed", Content = "Config list updated.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
        end },
        { Title = "Clear Autoload", Callback = doClearAutoload }
    )

    CreateButton(CfgSection, "Reset All Elements", "Reset all elements to default", "rbxassetid://16932740082", function()
        for id, element in pairs(AllElements) do
            pcall(function()
                if element.Type == "Toggle" then
                    element:Set(false)
                elseif element.Type == "Slider" then
                    local min = element._data and element._data.MinValue or 0
                    element:Set(min)
                elseif element.Type == "Dropdown" then
                    if element._data and element._data.Multi then
                        element:Set({})
                    else
                        element:Set(nil)
                    end
                elseif element.Type == "Input" then
                    element:Set("")
                end
            end)
        end
        MakeNotify({ Title = "Config", Description = "Reset", Content = "All elements reset to default.", Color = Color3.fromRGB(150,150,170), Delay = 2 })
    end)

    -- backward compat refs
    local LoadConfigDropdown = SelectConfigDropdown
    local DeleteConfigDropdown = SelectConfigDropdown
    
    -- Switch to first tab is handled by Window:Show()

    -- Window Methods
    local Window = {}
    
    function Window:CreateTab(tabName, iconId)
        return CreateTabButton(tabName, iconId, false)
    end
    
    function Window:AddParagraph(tabContainer, title, content)
        return CreateParagraph(tabContainer, title, content)
    end

    function Window:AddTextHeader(tabContainer, title)
        return CreateTextHeader(tabContainer, title)
    end

    function Window:AddWelcomeCard(tabContainer)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        local LP = game:GetService("Players").LocalPlayer
        local WC = Instance.new("Frame")
        WC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WC.BackgroundTransparency = 0.935
        WC.BorderSizePixel = 0
        WC.Size = UDim2.new(1, 0, 0, 88)
        WC.LayoutOrder = 0
        WC.Name = "WelcomeCard"
        WC.Parent = tabContainer
        Instance.new("UICorner", WC).CornerRadius = UDim.new(0, 4)

        local AF = Instance.new("Frame")
        AF.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        AF.BorderSizePixel = 0
        AF.Position = UDim2.new(0, 14, 0.5, -28)
        AF.Size = UDim2.new(0, 56, 0, 56)
        AF.Parent = WC
        Instance.new("UICorner", AF).CornerRadius = UDim.new(1, 0)

        local AI = Instance.new("ImageLabel")
        AI.Size = UDim2.new(1, 0, 1, 0)
        AI.BackgroundTransparency = 1
        AI.BorderSizePixel = 0
        AI.Parent = AF
        Instance.new("UICorner", AI).CornerRadius = UDim.new(1, 0)

        task.spawn(function()
            local ok, img = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and img then AI.Image = img end
        end)

        local NL = Instance.new("TextLabel")
        NL.Font = Enum.Font.GothamBold
        do
            local _n = LP.Name
            local _m = #_n > 3 and _n:sub(1, #_n - 3) .. "***" or "***"
            NL.Text = "Hey, " .. _m .. "!"
        end
        NL.TextColor3 = Color3.fromRGB(240, 240, 255)
        NL.TextSize = 14
        NL.TextXAlignment = Enum.TextXAlignment.Left
        NL.BackgroundTransparency = 1
        NL.BorderSizePixel = 0
        NL.Size = UDim2.new(1, -96, 0, 20)
        NL.Position = UDim2.new(0, 82, 0, 24)
        NL.Parent = WC

        local SL = Instance.new("TextLabel")
        SL.Font = Enum.Font.GothamBold
        SL.Text = "Welcome to Limbo Hub"
        SL.TextColor3 = Color3.fromRGB(255, 255, 255)
        SL.TextTransparency = 0.6
        SL.TextSize = 12
        SL.TextXAlignment = Enum.TextXAlignment.Left
        SL.BackgroundTransparency = 1
        SL.BorderSizePixel = 0
        SL.Size = UDim2.new(1, -96, 0, 16)
        SL.Position = UDim2.new(0, 82, 0, 50)
        SL.Parent = WC
    end
    
    function Window:AddButton(tabContainer, title, content, iconId, callback)
        return CreateButton(tabContainer, title, content, iconId, callback)
    end
    
    function Window:AddToggle(tabContainer, title, content, defaultValue, callback, elementId)
        return CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
    end
    
    function Window:AddInput(tabContainer, title, content, placeholder, callback, elementId)
        return CreateInput(tabContainer, title, content, placeholder, callback, elementId)
    end
    
    function Window:AddDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        return CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
    end
    
    function Window:AddMultiDropdown(tabContainer, title, content, options, defaultValue, callback, elementId)
        return CreateDropdown(tabContainer, title, content, options, true, defaultValue, callback, elementId)
    end
    
    function Window:AddSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId, showKnob)
        return CreateSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId, showKnob)
    end
    
    function Window:AddLineSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId)
        return CreateSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId, false)
    end

    function Window:AddImageBox(tabContainer, title, content, imageId, size, callback, elementId)
        return CreateImageBox(tabContainer, title, content, imageId, size, callback, elementId)
    end

    -- FIXED: Renamed from AddSection to AddDivider
    function Window:AddDivider(tabContainer, title)
        return CreateDivider(tabContainer, title)
    end

    function Window:AddCollapsible(tabContainer, title, defaultOpen)
        return CreateCollapsible(tabContainer, title, defaultOpen)
    end

    function Window:AddButtonGrid(tabContainer, btn1Config, btn2Config)
        return CreateButtonGrid(tabContainer, btn1Config, btn2Config)
    end

    function Window:AddColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
        return CreateColorPicker(tabContainer, title, content, defaultColor, callback, elementId)
    end

    function Window:AddKeybind(tabContainer, title, content, defaultKey, callback, elementId)
        return CreateKeybind(tabContainer, title, content, defaultKey, callback, elementId)
    end
    
    function Window:Notify(notifyConfig)
        return MakeNotify(notifyConfig)
    end
    
    function Window:SetTheme(themeName)
        return ConfigSystem:SetTheme(themeName)
    end
    
    function Window:SetVersion(newVersion)
        if not newVersion or newVersion == "" then return end
        Version = tostring(newVersion)
        Window.Version = Version
        if Row1 then
            local vb = Row1:FindFirstChild("VersionBadge")
            if vb then
                local lbl = vb:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = Version end
            end
        end
    end

    function Window:SaveConfig(name)
        local configData = {}
        for id, element in pairs(AllElements) do
            if element.Type == "Toggle" then
                configData[id] = element.Value
            elseif element.Type == "Slider" then
                configData[id] = element.Value
            elseif element.Type == "Dropdown" then
                configData[id] = element.Value
            elseif element.Type == "Input" then
                configData[id] = element.Value
            elseif element.Type == "ColorPicker" then
                configData[id] = {element.Value.R, element.Value.G, element.Value.B}
            elseif element.Type == "Keybind" then
                configData[id] = element.Value and element.Value.Name or nil
            end
        end
        local notifyData = ConfigSystem:SaveConfig(name, configData)
        MakeNotify(notifyData)
    end
    
    function Window:LoadConfig(name)
        local notifyData, configData = ConfigSystem:LoadConfig(name)
        MakeNotify(notifyData)
        if configData then
            for id, val in pairs(configData) do
                if AllElements[id] then
                    if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                        AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                    elseif AllElements[id].Type == "Keybind" and val then
                        AllElements[id]:Set(Enum.KeyCode[val])
                    else
                        AllElements[id]:Set(val)
                    end
                end
            end
        end
    end
    
    function Window:DeleteConfig(name)
        local notifyData = ConfigSystem:DeleteConfig(name)
        MakeNotify(notifyData)
    end
    
    function Window:GetConfigs()
        return ConfigSystem:GetConfigList()
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:SetActiveTab(tabName)
        if TabSwitchFns[tabName] then
            TabSwitchFns[tabName]()
        end
    end

    function Window:Toggle()
        DropShadowHolder.Visible = not DropShadowHolder.Visible
        return DropShadowHolder.Visible
    end

    function Window:Show()
        DropShadowHolder.Visible = true
        task.spawn(function()
            pcall(function()
                if isfile(AutoloadFile) then
                    local autoName = readfile(AutoloadFile)
                    if autoName and autoName ~= "" then
                        local _, configData = ConfigSystem:LoadConfig(autoName)
                        if configData then
                            for id, val in pairs(configData) do
                                pcall(function()
                                    if AllElements[id] then
                                        if AllElements[id].Type == "Toggle" and val == false then
                                            return
                                        end
                                        if AllElements[id].Type == "ColorPicker" and type(val) == "table" then
                                            AllElements[id]:Set(Color3.new(val[1], val[2], val[3]))
                                        elseif AllElements[id].Type == "Keybind" and val then
                                            AllElements[id]:Set(Enum.KeyCode[val])
                                        else
                                            AllElements[id]:Set(val)
                                        end
                                    end
                                end)
                            end
                            CurrentConfigName = autoName
                            updateCfgStatus()
                            MakeNotify({ Title = "Config", Description = "Autoloaded", Content = "\"" .. autoName .. "\" loaded!", Color = Color3.fromRGB(150,150,170), Delay = 3 })
                        end
                    end
                end
            end)
        end)
    end
    
    return Window
end

function Limbo:Notify(config)
    MakeNotify(config)
end

return Limbo
