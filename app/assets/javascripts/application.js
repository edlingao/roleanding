// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .


function readURL(input) {
    if (input.files && input.files[0]) {
        let reader = new FileReader();

        reader.onload =  (e)=> {
            let image = document.querySelector('#blah')
                image.src = e.target.result;
        };

        reader.readAsDataURL(input.files[0]);
    }
    let container = document.getElementById('hidden');
    let close;
    container.className = "image-preview show-image-preview hidden";

    close = document.querySelector('#close');
    
    close.addEventListener('click', ()=>{
        container.className = "hidden hide-image-preview"
        console.log("something");
    });
}

function closePostPic(container){
    
    close = document.querySelector('#close');
    
}


function changePicture(input){
    if (input.files[0]) {
        let img = document.querySelector('#image');
        let file = document.querySelector('#user_profile_pic');

        let reader = new FileReader();
        reader.onload = (e)=> {
            img.src = e.target.result;
        }
        reader.readAsDataURL(file.files[0])
    }
}



function changePicForm(){
    let picForm = document.querySelector('#change');
    picForm.className = "change-pic-form anim";
}
function hidePicForm(){
    let picForm = document.querySelector('#change');
    picForm.className = "hidden change-pic-form back-anim";
    
}



function AddLike(like){
    
    likes = 0;
}

function SubstractLike(dislike){
    console.log(dislike);
}

function addLikeEventListener(){
    let likesButtons = document.querySelectorAll("[id='like']");
    let dislikeButtons = document.querySelectorAll("[id='dislike']");

    likesButtons.forEach(like => {
        like.addEventListener('click', ()=>{
            let div = like.parentElement;
            let counter = div.querySelector("#like-counter");
            let likes = parseInt(counter.innerHTML);
            let icon = like.
            likes += 1;
            counter.innerHTML = likes;

            console.log(counter);
        });
    });

    dislikeButtons.forEach(dislike => {
        dislike.addEventListener('click', SubstractLike(dislike));
    });
}

let changeButton;
let closeButton; 
