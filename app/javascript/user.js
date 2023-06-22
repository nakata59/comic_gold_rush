window.addEventListener('load', function() {
    const selectableOptions = document.getElementById("selectable-options");
  
    function addSelectableOptions(keyword) {
      while (selectableOptions.firstChild) {
        selectableOptions.removeChild(selectableOptions.firstChild);
      }
      let options = document.getElementById("select").children;
      let usersField = document.getElementById("users");
  
      for (let i = 0; i < options.length; i++) {
        let appendSelectableOption = document.createElement("div");
  
        let userId = options[i].value;
        appendSelectableOption.setAttribute('data-id', userId);
  
        let userName = document.createElement("a");
        userName.href = "/users/" + userId; // ユーザーの詳細ページへのリンク先を設定
        userName.textContent = options[i].innerText; // リンクのテキストを設定
        userName.classList.add("block");
        appendSelectableOption.appendChild(userName);
  
        appendSelectableOption.classList.add(
          "cursor-pointer",
          "hover:bg-gray-200",
          "border-b-2",
          "border-gray-200",
          "p-2"
        );
  
        if (usersField.value.split(",").includes(String(appendSelectableOption.getAttribute('data-id')))) {
          appendSelectableOption.classList.add("is_selected");
        }
  
        if (userName.textContent.indexOf(keyword) !== -1) {
          selectableOptions.appendChild(appendSelectableOption);
        }
      }
    }
  
    serch_box.addEventListener("input", function() {
      if (this.value !== "") {
        addSelectableOptions(this.value);
      }
    });
  
    function setDefaultValueInEdit() {
      let usersField = document.getElementById("users");
      let options = document.getElementById("select").children;
      let selectedOptionsArray = usersField.value.split(",");
      for (let i = 0; i < options.length; i++) {
        if (selectedOptionsArray.includes(String(options[i].value))) {
          selectedMemberNames.innerHTML += options[i].innerHTML + ",";
        }
      }
    }
    setDefaultValueInEdit();
  });