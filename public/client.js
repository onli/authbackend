// url of our LA instance
var url = "http://localhost:9292"

initForm(document.querySelector('#letsauth'));

// initialize a minimal login form and catch its submit event to use the LA porototype api
function initForm(container) {
    container.innerHTML = '<form method="POST"><input type="email" name="email" /><button type="submit">Sign in with your email</button></form>'
    container.querySelector('form').addEventListener("submit", function(e) {
        e.preventDefault();
        confirm(e.target.querySelector('input').value); // there is probably a better way to send the form
        showLoader(container);
    })
}

// send the mail to be confirmed to LA
function confirm(mail) {    
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url + '/confirm', true);

    var formData = new FormData();
    formData.append('mail', mail);

    xhr.onload = function(e) {
        if (this.status == 200) {
            console.log('mail given to LA instance');
            checkConfirm(mail);
        }
    };

    xhr.send(formData);
}

// Check LA instance until the mail is confirmed
var confirmInterval = null;
function checkConfirm(mail) {
    confirmInterval = setInterval(function() {
        console.log("checking mail confirm status");
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url + '/confirm?mail=' + mail, true);
        xhr.onload = function(e) {
            if (this.status == 200) {
                console.log("LA confirmed email to browser");
                clearInterval(confirmInterval);
                showActivity();
                notifyServer(this.responseText);
                
            }
        }
        xhr.send();
    }, 1000);
}

function notifyServer(token) {
    console.log("checking token confirm status");
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/validate', true);
    var formData = new FormData();
    formData.append('token', token);
    xhr.onload = function(e) {
        if (this.status == 200) {
            console.log("LA confirmed token to server");
            showSuccess();
        }
        if (this.status == 403) {
            console.log("LA id not confirm token to server");
            showFailure();
        }
    }
    xhr.send(formData);
}

function showSuccess() {
    document.querySelector('#letsauth').innerHTML = "Success! You are logged in.";
}

function showFailure() {
    document.querySelector('#letsauth').innerHTML = "Error, you are not logged in";
}

function showActivity() {
    document.querySelector('#letsauth').innerHTML = "Confirming login…";
}

function showLoader(container) {
    container.innerHTML = "Please check your mails!";
}