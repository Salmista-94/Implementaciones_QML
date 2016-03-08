import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
//import QtQuick.Controls.Styles.Flat 1.0 as Flat
import QtQuick.Extras 1.4

import QtQuick.Window 2.2

Item {
    id: editor
    objectName: "TimeEdit"
    //color: "grey"
    //visible: true
    //property var _regExp: "\d{1:2}/\d\d/\d\d\s\d{1:2}:\d\d"

    width: 120
    height: 25


    property var regExp: /\d{1,2}:\d\d/
    readonly property string text: t_Field.text
    property bool readOnly: true
    property var hAligment: TextInput.AlignHCenter
    property alias font: t_Field.font //: TextSingleton.font

    function moreTime(){
        __increment(t_Field, 1)
    }
    function minusTime(){
        __increment(t_Field, -1)
    }

    signal moreTimeContinous()
    signal minusTimeContinous()


    function setText(str){
        t_Field.text = str
    }

    Component.onCompleted: editor.setText(new Date().toLocaleString(Qt.locale(), "h:mm"))


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
        var item = 0
        var s = ""
    
        var hora = 0
        var minu = 0
    
        var index = _str.length-1
        var tip = pos === index+1?  0: 1
        var c = null

        for(var i= index; i >= 0; i--){
            c = _str[i]
            if (c === ":"){
                item += 1
                minu = Number(s)
                s = ""
            }else
                s = c + s
            
            if (index === pos){
                tip = item
                //console.log("index:",index, "pos:", pos, "tip:", tip)
            }

            index -= 1
        }
        hora = Number(s)

        
        //console.log(hora+":"+minu, tip)
     
        //var maxDays = daysOfMonth(mes, anio)
        var rangetype = {0:_range0, 1:_range1}//, 2:_range2, 3:_range3, 4: [maxDays,1]}
    
        if (value > rangetype[tip][0])
            value = rangetype[tip][0]
        else if (value < rangetype[tip][1])
            value = rangetype[tip][1]
        //console.log(hora+":"+minu, tip)
        
        if (tip === 0)
            minu = value
        else if (tip === 1)
            hora = value
        
        if (minu.toString().length < 2)
            minu = "0" +  minu

        //console.log(dia+"/"+mes+"/"+syear+"        "+hora+":"+minu,       _year)

        return (hora+":"+minu)//dia+"/"+mes+"/"+syear+"        "+
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
        anchors.fill: editor
        //anchors.centerIn: parent
        validator: RegExpValidator { regExp: editor.regExp }//_regExp
        readOnly: editor.readOnly
        horizontalAlignment: editor.hAligment
        //font: editor.font
        focus: true
        z: 1
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
        width: 15
        color: "#bbb"//"#e1e1e1"
        radius: 2
        border.width: 1
        border.color: "#777"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.topMargin: 0
        z: 1

        ToolButton {
            id: _subBut1
            width: parent.width
            height: parent.height/2
            anchors.right: parent.right
            anchors.bottom: _subBut2.top
            anchors.top: parent.top
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.topMargin: 0
            checkable: false
            iconSource: "images/arrow-up-05-claro.png"
            onClicked: editor.moreTime()
        }
        ToolButton {
            id: _subBut2
            width: parent.width
            height: parent.height/2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            checkable: false
            iconSource: "images/arrow-down-05-claro.png"
            onClicked: editor.minusTime()
        }
/*
        Rectangle {
            id: rec_middle
            y: parent.height/2-1//Math.round()
            width: parent.width
            height: 1
            color: "#777"
        }*/
    }
}
