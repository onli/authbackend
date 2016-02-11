// url of our LA instance
var url = "http://localhost:9292"

initForm(document.querySelector('#letsauth'));

// initialize a minimal login form and catch its submit event to use the LA porototype api
function initForm(container) {
    container.innerHTML = '<form method="POST"><input type="email" name="mail" /><button type="submit">Sign in with your email</button></form>'
    container.querySelector('form').addEventListener("submit", function(e) {
        e.preventDefault();
        confirm(e.target);
        showLoader(container);
    })
}

// send the mail to be confirmed to LA
function confirm(form) {    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url + '/confirm', true);

    var formData = new FormData(form);
    var buffer = new Int8Array(10);
    window.crypto.getRandomValues(buffer);
    var nonce = "";
    for (var i = 0; i < buffer.length; i++) {
        nonce += buffer[i];
    }
    formData.append("session_id", nonce);
    
    xhr.onload = function(e) {
        if (this.status == 200) {
            console.log('mail given to LA instance');
            checkConfirm(nonce);
        }
    };

    xhr.send(formData);
}

// Check RP until the mail is confirmed
var confirmInterval = null;
function checkConfirm(nonce) {
    confirmInterval = setInterval(function() {
        console.log("checking mail confirm status");
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '/confirm?session_id=' + nonce, true);  // will check session
        xhr.onload = function(e) {
            if (this.status == 200) {
                console.log("RP knows LA confirmed email to browser");
                clearInterval(confirmInterval);
                showSuccess();
            }
        }
        xhr.send();
    }, 1000);
}

function showSuccess() {
    document.querySelector('#letsauth').innerHTML = "Success! You are logged in.";
}

function showLoader(container) {
    container.innerHTML = "Please check your mails!";
}