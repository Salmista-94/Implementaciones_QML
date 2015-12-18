import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
//import QtQuick.Controls.Styles.Flat 1.0 as Flat
import QtQuick.Extras 1.4

import QtQuick.Window 2.2

Item {
    id: editor
    objectName: "DateEdit"
    //color: "grey"
    //visible: true
    //property var _regExp: "\d{1:2}/\d\d/\d\d\s\d{1:2}:\d\d"

    width: 120
    height: 25


    property var regExp: /\d{1,2}\/\d\d\/\d\d/
    readonly property string text: t_Field.text
    property bool readOnly: true
    property int hAligment: TextInput.AlignHCenter
    property alias font: t_Field.font //: TextSingleton.font
    property bool showWeekNumbers: true

    signal calendarActived()

    signal yearChanged(int _i)
    signal monthChanged(int _i)
    signal dayChanged(int _i)
    signal dateChanged(string str)


    onMonthChanged: _subCal.visibleMonth= _i -1
    onYearChanged: _subCal.visibleYear= _i


    function setText(str){
        t_Field.text = str
    }

    function hideCalendar(){
        _subBut.checked= false
    }

    Component.onCompleted: editor.setText(new Date().toLocaleString(Qt.locale(), "d/MM/yy"))

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
    }


    property var _range0:  [59,0]
    property var _range1:  [23,0]
    property var _range2:  [99,0]
    property var _range3:  [12,1]

    //property var _rangetype: DelegateModelGroup{}
/**/

    function getDateString(_str, pos, value){
        var item = 2
        var _mes_dia = false
        var s = ""
        var anio = 0
        var mes = 1
        var dia = 1
        
        var index = _str.length-1
        var tip = pos === index+1?  2: 4
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
            }else
                s = c + s
            
            if (index === pos){
                tip = item
                //console.log("index:",index, "pos:", pos, "tip:", tip)
            }

            index -= 1
        }
        
        dia = Number(s)

        
        //console.log(dia+"/"+mes+"/"+anio, tip)

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
        //console.log(dia+"/"+mes+"/"+anio, tip)
     
        var maxDays = daysOfMonth(mes, anio)
        var rangetype = {2:_range2, 3:_range3, 4: [maxDays,1]}
    
        if (value > rangetype[tip][0])
            value = rangetype[tip][0]
        else if (value < rangetype[tip][1])
            value = rangetype[tip][1]
        //console.log(dia+"/"+mes+"/"+anio, tip)
        
        if (tip === 2){
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

        //console.log(dia+"/"+mes+"/"+syear+"        "+hora+":"+minu,       _year)

        return (dia+"/"+mes+"/"+syear)
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
        if (event.key === Qt.Key_Up) {
            __increment(t_Field, 1);
        }else if (event.key === Qt.Key_Down) {
            __increment(t_Field, -1);
        }else if (event.key === Qt.Key_Left) {
            t_Field.cursorPosition = (t_Field.cursorPosition >= 3? t_Field.cursorPosition -3: 0)
            t_Field.selectWord()
            if (isNaN(Number(t_Field.selectedText))){
                t_Field.cursorPosition = t_Field.cursorPosition -2
                t_Field.selectWord()
            }
            //print("Left")
        }else if (event.key === Qt.Key_Right) {// || event.key === Qt.Key_Tab
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
        anchors.fill: editor
        //anchors.centerIn: parent
        focus: true
        validator: RegExpValidator { regExp: editor.regExp }//_regExp
        text: editor.text//_Today
        readOnly: editor.readOnly
        horizontalAlignment: editor.hAligment
        //font: editor.font
        z: 2
        Keys.onPressed: event.accepted = isMovedPressed(event.key)
        Component.onCompleted: {
            font.family = "MS Shell Dlg 2"
            font.pixelSize = 12
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




    Rectangle{//para evitar problemas de seleccion, con el combobox que esta debajo
        id: calendario
        width: 200
        height: 180
        anchors.top: editor.bottom
        anchors.left: editor.left
        anchors.topMargin: 0
        anchors.leftMargin: 0
        visible: _subBut.checked
        color: "transparent"
        z: 1
        /*
        SequentialAnimation {
            id: animateColor;
            loops: Animation.Infinite
            PropertyAnimation {target: calendario; properties: "color"; to: "#777"; duration: 100}
            PropertyAnimation {target: calendario; properties: "color"; to: "#f16234"; duration: 100}
        }*/ 
        Calendar {
            id: _subCal
            anchors.fill: parent
            z:1/**/
            focus: visible//
            //anchors.margins: 5
            frameVisible: true
            weekNumbersVisible: editor.showWeekNumbers
            onDoubleClicked: {
                editor.setText(date.toLocaleString(Qt.locale(), "d/MM/yy"))
                editor.hideCalendar()
            }
            Component.onCompleted: print("se asume fecha actual")
        }
        MouseArea{
            anchors.fill: parent
            propagateComposedEvents: false
            onEntered: 1+1//animateColor.start()
        }
        
            /**/
    }


}
