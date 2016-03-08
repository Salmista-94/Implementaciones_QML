import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
//import QtQuick.Controls.Styles.Flat 1.0 as Flat
import QtQuick.Extras 1.4

import QtQuick.Window 2.2

Item {
    id: editor
    objectName: "DateTimeEdit"
    //color: "grey"
    //visible: true
    //property var _regExp: "\d{1:2}/\d\d/\d\d\s\d{1:2}:\d\d"

    width: 120
    height: 25


    property int spacer: 8
    property string s_Spacer: "        "
    property var regExp 
    readonly property string text: t_Field.text
    property bool readOnly: true
    property int hAligment: TextInput.AlignLeft
    property alias font: t_Field.font //: TextSingleton.font
    //property int pixelSize//: t_Field.font.pixelSize //: TextSingleton.font
    property bool showWeekNumbers: true
    //property var _root: findRoot()

    signal calendarActived()

    signal yearChanged(int _i)
    signal monthChanged(int _i)
    signal dayChanged(int _i)
    signal dateChanged(string str)


    onMonthChanged: _subCal.visibleMonth= _i -1
    onYearChanged: _subCal.visibleYear= _i


    function findRoot(){
        var rt = editor.parent
        var x = editor.x
        var y = editor.y
        while(rt.parent !== undefined && rt.parent !== null){
            x = x + rt.x
            y = y + rt.y
            rt = rt.parent
        }
        x = x - rt.x
        y = y - rt.y

        return {"rt":rt, "x":x, "y":y}
    }


    function setSpacer(spc){
        if (!spc > 0){
            spacer = 8
        }
    }
    function hideCalendar(){
        _subBut.checked= false
    }

    function makeSpace(){
        var spc = ""
        for (var i = 0; i<spacer; i++) {
            spc = spc+ " "
        }
        s_Spacer = spc
    }
    function setText(str){
        t_Field.text = str
    }

    function getHour(){
        var sHora= ""
        var c = ""
        for (var i= 8; i<t_Field.text.length; i++) {
            c = t_Field.text[i]
            if (c !== " ")
                sHora = sHora + c
        }
        return sHora
    }


    Component.onCompleted:{
        regExp = /\d{1,2}\/\d\d\/\d\d\s{spacer}\d{1,2}:\d\d/
        makeSpace()
        editor.setText(new Date().toLocaleString(Qt.locale(), "d/MM/yy"+s_Spacer+"h:mm"))
        //print("_root", _root, _root["rt"], _root["x"], _root["y"])
    }


    function __increment(obj, units){
        var p1 = 0
        var p2 = 0
        obj.selectWord()
        if (isNaN(Number(obj.selectedText))){
            obj.cursorPosition= obj.cursorPosition -2
            obj.selectWord()
        }
        if (obj.selectedText.length > 2){
            p1 = Math.min(obj.selectionStart, obj.selectionEnd)
            obj.cursorPosition= p1
            obj.selectWord()
        }

        var value = Number(obj.selectedText) + units

        var newText = getDateString(obj.text, obj.cursorPosition, value)

        p1 = Math.min(obj.selectionStart, obj.selectionEnd)
        var tmp = obj.validator
        obj.validator= null
        obj.text= newText
        obj.cursorPosition= p1
        obj.selectWord()
        obj.validator= tmp  
        editor.dateChanged(newText)
    }


    property var _range0:  [59,0]
    property var _range1:  [23,0]
    property var _range2:  [99,0]
    property var _range3:  [12,1]

    //property var _rangetype: DelegateModelGroup{}
/**/

    function getDateString(_str, pos, value){
        var item = 0
        var passed = false
        var _mes_dia = false
        var s = ""
        var anio = 0
        var mes = 1
        var dia = 1
    
        var hora = 0
        var minu = 0
    
        var index = _str.length-1
        var tip = pos === index+1?  0: 4
        var c = null

        for(var i= index; i >= 0; i--){
            c = _str[i]
            if (c === ":"){
                item += 1
                minu = Number(s)
                s = ""
            }else if (c === "/"){
                item += 1
                _mes_dia = ! _mes_dia
                if (_mes_dia){
                    anio = Number("20"+s)
                    s = ""
                }else{
                    mes = Number(s)
                    s = ""
                }
            }else if (c === " "){
                if (!passed){
                    item += 1
                    passed = true
                    hora = Number(s)
                    s = ""
                }
            }else
                s = c + s
            
            if (index === pos){
                tip = item
                //console.log("index:",index, "pos:", pos, "tip:", tip)
            }

            index -= 1
        }
        
        dia = Number(s)

        
        //console.log(dia+"/"+mes+"/"+anio+"        "+hora+":"+minu, tip)

        if (tip === 2){
            if (value > 99)
                value = 99
            else if (value < 0)
                value = 0
            if (value.toString().length < 2)
                value = "0" +  value
            anio = Number("20"+value)
            editor.yearChanged(anio)
        }else if (tip === 3){
            if (value > 12)
                value = 12
            else if (value < 1)
                value = 1
            mes = value
            editor.monthChanged(mes)
        }
        //console.log(dia+"/"+mes+"/"+anio+"        "+hora+":"+minu, tip)
     
        var maxDays = daysOfMonth(mes, anio)
        var rangetype = {0:_range0, 1:_range1, 2:_range2, 3:_range3, 4: [maxDays,1]}
    
        if (value > rangetype[tip][0])
            value = rangetype[tip][0]
        else if (value < rangetype[tip][1])
            value = rangetype[tip][1]
        //console.log(dia+"/"+mes+"/"+anio+"        "+hora+":"+minu, tip)
        
        if (tip === 0)
            minu = value
        else if (tip === 1)
            hora = value
        else if (tip === 2){
            if (dia > maxDays)
                dia = maxDays
        }else if (tip === 3){
            if (dia > maxDays)
                dia = maxDays
        }else if (tip === 4){
            dia = value
            editor.dayChanged(dia)
        }

        var syear = ""
        var _year = anio.toString()
        for(var i= 2; i < 4; i++)
            syear += _year[i]

        if (mes.toString().length < 2)
            mes = "0" +  mes
        if (minu.toString().length < 2)
            minu = "0" +  minu

        //console.log(dia+"/"+mes+"/"+syear+"        "+hora+":"+minu,       _year)

        return (dia+"/"+mes+"/"+syear+editor.s_Spacer+hora+":"+minu)
    }

    function bisiesto(anio){
        return anio % 4 === 0 && (anio % 100 !== 0 || anio % 400 === 0)
    }

    function daysOfMonth(_m, anio){
        //#assert _m > 0 and _m < 13, _m
        if (_m === 1 || _m === 3 || _m === 5 || _m === 7 || _m === 8 || _m === 10 || _m === 12)
            return 31
        else if (_m === 2)
            return (bisiesto(anio)? 29: 28)
        else
            return 30
    }

    function isMovedPressed(key){
        if (key === Qt.Key_Up) {
            __increment(t_Field, 1);
        }else if (key === Qt.Key_Down) {
            __increment(t_Field, -1);
        }else if (key === Qt.Key_Left) {
            t_Field.cursorPosition = (t_Field.cursorPosition >= 3? t_Field.cursorPosition -3: 0)
            t_Field.selectWord()
            if (isNaN(Number(t_Field.selectedText))){
                t_Field.cursorPosition = t_Field.cursorPosition -2
                t_Field.selectWord()
            }
            //print("Left")
        }else if (key === Qt.Key_Right) {// || key === Qt.Key_Tab
            t_Field.cursorPosition = t_Field.cursorPosition +2
            t_Field.selectWord()
            if (isNaN(Number(t_Field.selectedText)))
                t_Field.selectWord()
            //print("Right")
        }else return false

        return true
    }



    TextField {//"ddd  d/MMM/yy   h:mm 'Hs'"
        id:t_Field
        anchors.fill: parent
        //anchors.centerIn: parent
        focus: true
        validator: RegExpValidator { regExp: editor.regExp }//_regExp
        //text: editor.text_Today
        readOnly: editor.readOnly
        horizontalAlignment: editor.hAligment
        //font: editor.font
        z: 1
        Keys.onPressed: event.accepted = isMovedPressed(event.key)
        Component.onCompleted: {
            //editor.font = font
            font.family = "MS Shell Dlg 2"
            font.pixelSize = 13
        }
        
    }
    MouseArea{
        anchors.fill: t_Field
        scrollGestureEnabled: true//no es estrictamente necesaria
        onWheel: __increment(t_Field, wheel.angleDelta.y/120)
    }
    
    Rectangle{
        id: calendarButton
        width: 20
        color: "#777"
        radius: 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        z:2

        ToolButton {
            id: _subBut
            checkable: true
            checked: false
            anchors.fill: parent
            iconSource: "images/arrow-down.png"
            //onClicked: calendario.visible = !calendario.visible
        }
    }


    //Window{//para evitar problemas de seleccion, con el combobox que esta debajo
    Rectangle{
        //InfoBox
        id: calendario
        //_-flags: Qt.Popup
        //modality: Qt.ApplicationModal
        width: 200
        height: 180
        visible: _subBut.checked
        
        //x: editor.x//+editor.width
        //y: editor.y+editor.height
        anchors.left: editor.left
        anchors.top: editor.bottom

        //x: editor.x+editor.parent.x//+editor.width
        //y: editor.y+editor.height+editor.parent.y

        /*
        x: _root["x"]+_root["rt"].x
        y: _root["y"]+_root["rt"].y+editor.height
        *//*
        anchors.top: editor.bottom
        anchors.left: editor.left
        anchors.topMargin: 0
        anchors.leftMargin: 0*/
        //color: "transparent"
        //z: 1
        /*
        SequentialAnimation {
            id: animateColor;
            loops: Animation.Infinite
            PropertyAnimation {target: calendario; properties: "color"; to: "#777"; duration: 100}
            PropertyAnimation {target: calendario; properties: "color"; to: "#f16234"; duration: 100}
        }*/
        Calendar {// using that style: https://bugreports.qt.io/browse/QTBUG-51592
            id: _subCal
            anchors.fill: parent
            z:1000/**/
            focus: visible//
            //anchors.margins: 5
            frameVisible: true
            weekNumbersVisible: editor.showWeekNumbers
            onDoubleClicked: {
                editor.setText(date.toLocaleString(Qt.locale(), "d/MM/yy")+editor.s_Spacer+editor.getHour())
                //print("esta seccion corrompe la HORA")
                editor.hideCalendar()
            }
            Component.onCompleted: print("se asume fecha actual")
        }
        MouseArea{
            anchors.fill: parent
            propagateComposedEvents: false
            onEntered: 1+1//animateColor.start()
        }/**/
    }

}
