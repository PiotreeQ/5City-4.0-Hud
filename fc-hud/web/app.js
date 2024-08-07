// discord.gg/piotreqscripts

const showNotification = ((data) => {
    const $newNotify = $(`
    <div class="notification ${data.type}">
        ${data.type == 'info' ? `<i class="fa-light fa-circle-info"></i>` : data.type == 'warning' ? `<i class="fa-light fa-exclamation-triangle"></i>` : `<i class="fa-light fa-circle-info"></i>`}
        <span>${data.label}</span>
        <div class="notify-bar">
            <div style="width: 100%" class="bar-fill"></div>
        </div>
    </div>`);
    $('.notify-wrapper').prepend($newNotify);
    setTimeout(() => {
        $newNotify.css('transform', 'translateX(0)');
        setTimeout(() => {
            $($newNotify).find('.bar-fill').animate({
                width: '0%'
            }, data.duration, () => {
                $newNotify.css({
                    'transform': 'translateX(150%)',
                    'opacity': '0.0'
                });
                setTimeout(() => {
                    $newNotify.remove();
                }, 1000);
            })
        }, 500);
    }, 100);
})

let hudState = false;
let inVeh = false;

const ToggleMainHud = (() => {
    $('.main-hud-wrapper').css('transform', `translateX(${hudState ? '0' : '150%'})`);
    $('.main-hud-wrapper').animate({
        opacity: hudState ? '1.0' : '0.0'
    }, 250);
})

const ToggleCarHud = ((state) => {
    $('.car-hud-wrapper').css('transform', `translateY(${state ? '0' : '150%'})`);
    $('.car-hud-wrapper').animate({
        opacity: state ? '1.0' : '0.0'
    }, 250);
    $('.street-wrapper').css('transform', `translateX(${state ? '0' : '-150%'})`);
    $('.street-wrapper').animate({
        opacity: state ? '1.0' : '0.0'
    }, 250);
})

const UpdateStatus = ((key, value) => {
    let percentage = value;
    let perimeter = 180 * 4; 
    let dashLength = (percentage / 100) * perimeter;
    let offset = perimeter / 2.6;
    
    $(`#${key}x`).attr('stroke-dasharray', `${value * 10} 1000`);
    $(`#${key}x`).attr('stroke-dashoffset', offset);
})

const voiceModes = {
    ["1"]: 50,
    ["2"]: 65,
    ["3"]: 100
}
window.addEventListener("message", (event) => {
    let data = event.data;
    switch(data.action) {
        case 'ToggleHud':
            hudState = data.state;
            ToggleMainHud();
            if (inVeh) {
                ToggleCarHud(hudState);
            }
            break;
        case 'UpdateMainHud':
            for (const [key, value] of Object.entries(data.hud)) {
                if (key == 'voice') {
                    UpdateStatus(key, voiceModes[value.mode.toString()]);
                    $(`#${key}x`).css('filter', `brightness(${value.isTalking ? '125%' : '100%'})`)
                } else {
                    UpdateStatus(key, value);
                }
            }
            break;
        case 'ToggleCarHud':
            inVeh = data.state;
            ToggleCarHud(data.state);
            break;
        case 'UpdateCarHud':
            UpdateStatus('fuel', data.hud.fuel);
            $(`#car-speed`).text(data.hud.speed);
            $('#car-engine').css('opacity', data.hud.engine ? '1.0' : '0.5');
            $('#car-belt').css('opacity', data.hud.belt ? '1.0' : '0.5');
            $('#car-street').text(data.hud.street);
            $('.direction-box').text(data.hud.direction);
            break;
        case 'ShowNotification':
            showNotification(data.data);
            break;
    }
})