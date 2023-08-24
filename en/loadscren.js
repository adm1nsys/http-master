const lscreen = 1;
function getFontSizeRelativeToWindow(baseSize, minSize, maxSize) {
    let calculatedSize = window.innerWidth * baseSize / 1000;
    if (calculatedSize < minSize) {
        return minSize + "px";
    } else if (calculatedSize > maxSize) {
        return maxSize + "px";
    } else {
        return calculatedSize + "px";
    }
}
const shtoraT = document.createElement("div");
shtoraT.style.display = "flex";
shtoraT.style.width = "100%";
shtoraT.style.height = "50%";
shtoraT.style.position = "fixed";
shtoraT.style.left = "0px";
shtoraT.style.top = "0px";
shtoraT.style.background = "black";
shtoraT.style.zIndex = "99999999999999999";
shtoraT.style.transition = "4s";
shtoraT.style.alignItems = "center";
shtoraT.style.alignContent = "center";
shtoraT.style.justifyItems = "center";
shtoraT.style.justifyContent = "center";
document.body.appendChild(shtoraT);

const shtoraTtotle = document.createElement("div");
shtoraTtotle.style.display = "flex";
shtoraTtotle.style.fontFamily = "Roboto-Thin";
shtoraTtotle.style.fontSize = getFontSizeRelativeToWindow(60, 60, 200);
shtoraTtotle.textContent = "http-master";
shtoraTtotle.style.position = "relative";
shtoraTtotle.style.color = "rgb(255, 162, 0)";
shtoraTtotle.style.zIndex = "99999999999999999";
shtoraTtotle.style.transition = "4s";
shtoraT.appendChild(shtoraTtotle);

const shtoraB = document.createElement("div");
shtoraB.style.display = "flex";
shtoraB.style.width = "100%";
shtoraB.style.height = "50%";
shtoraB.style.position = "fixed";
shtoraB.style.right = "0px";
shtoraB.style.bottom = "0px";
shtoraB.style.background = "black";
shtoraB.style.zIndex = "99999999999999999";
shtoraB.style.transition = "4s";
shtoraB.style.justifyContent = "center";
shtoraB.style.alignItems = "end";
document.body.appendChild(shtoraB);

const shtoraBtotle = document.createElement("div");
shtoraBtotle.style.display = "flex";
shtoraBtotle.style.fontSize = getFontSizeRelativeToWindow(20, 20, 200);
shtoraBtotle.textContent = "http-master from Admin inc.";
shtoraBtotle.style.fontFamily = "Roboto-Regular"
shtoraBtotle.style.position = "relative";
shtoraBtotle.style.marginBottom = "20px";
shtoraBtotle.style.color = "rgb(124, 79, 0)";
shtoraBtotle.style.zIndex = "99999999999999999";
shtoraBtotle.style.transition = "4s";
shtoraB.appendChild(shtoraBtotle);

const shtorac111 = document.createElement("div");
shtorac111.style.display = "flex";
shtorac111.style.width = "100%";
shtorac111.style.height = "100%";
shtorac111.style.opacity = "1";
shtorac111.style.left = "0px";
shtorac111.style.right = "0px";
shtorac111.style.position = "fixed";
shtorac111.style.top = "0px";
shtorac111.style.bottom = "0px";
shtorac111.style.background = "none";
shtorac111.style.zIndex = "999999999999999999";
shtorac111.style.transition = "0.4s";
shtorac111.style.justifyContent = "center";
shtorac111.style.justifyItems = "center";
shtorac111.style.alignItems = "center";
shtorac111.style.alignContent = "center";
shtorac111.style.overflow = "hidden";
document.body.appendChild(shtorac111);

function animatels01() {
    if(linec1111.style.left === "-100%"){
        linec1111.style.transition = "1s";
        setTimeout(function() {
            linec1111.style.left = "100%";
        }, 100); 
    } else if(linec1111.style.left === "100%"){
        linec1111.style.transition = "0s";
        setTimeout(function() {
            linec1111.style.left = "-100%";
        }, 100); 
    }
}




const linec111 = document.createElement("div");
linec111.style.display = "flex";
linec111.style.position = "relative";
linec111.style.width = "100%";
linec111.style.height = "5px";
linec111.style.overflow = "hidden";
linec111.style.background = "rgb(124, 79, 0)";
linec111.style.transition = "1s";

const linec1111 = document.createElement("div");
linec1111.style.display = "flex";
linec1111.style.position = "absolute";
linec1111.style.top = "0px";
linec1111.style.left = "-100%";
linec1111.style.width = "50%";
linec1111.style.height = "100%";
linec1111.style.background = "rgb(255, 162, 0)";
linec1111.style.transition = "1s";


if(lscreen === 1){
document.body.appendChild(shtoraT);

document.body.appendChild(shtoraB);

document.body.appendChild(shtorac111);

shtorac111.appendChild(linec111);
linec111.appendChild(linec1111);
setInterval(animatels01, 1100); 

} else if (lscreen === 0){
//     //
    document.body.removeChild(shtoraT);

document.body.removeChild(shtoraB);

document.body.removeChild(shtorac111);
}

function lscrenclose() {

linec111.style.height = "0px";

  setTimeout(function() {
shtorac111.style.opacity = "0";
  setTimeout(function() {
shtoraT.style.top = "-200%";
}, 500); 

  setTimeout(function() {
shtoraB.style.bottom = "-200%";
}, 550); 

  setTimeout(function() {
document.body.removeChild(shtoraT);

document.body.removeChild(shtoraB);

document.body.removeChild(shtorac111);

}, 1600); 
}, 1000); 




}

onload = function () {
  setTimeout(function() {
lscrenclose() 
}, 5500); 

};
