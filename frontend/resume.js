var counterContainer = document.querySelector(".website-counter");
var visitCount = localStorage.getItem("page_view");
var resetButton = document.querySelector("#reset")

//Check if page_view entry is present
if (visitCount) {
    visitCount = Number(visitCount) + 1;
    localStorage.setItem("page_view", visitCount)
}
else {
    visitCount = 1;
    localStorage.setItem("page_view", 1);
}
counterContainer.innerHTML = visitCount;

// Adding onClick event listener
resetButton.addEventListener("click", () => {
    visitCount = 1;
    localStorage.setItem("page_view", 1);
    counterContainer.innerHTML = visitCount;
});

// Embedd the API
scripts/main.js

// GET API REQUEST
async function get_visitors() {
    // call post api request function
    //await post_visitor();
    try {
        let response = await fetch('https://139ilp5flj.execute-api.eu-central-1.amazonaws.com/default', {
            method: 'GET',
            headers: {
                //'x-api-key': 'JslbDfdt1F8fl7wE4CRIj1Oqidmtmzqw4lZ539Sj',
            }
        });
        let data = await response.json()
        document.getElementById("visitors").innerHTML = data['count'] + " visits.";
        console.log(data);
        return data;
    } catch (err) {
        console.error(err);
    }
}


get_visitors();


