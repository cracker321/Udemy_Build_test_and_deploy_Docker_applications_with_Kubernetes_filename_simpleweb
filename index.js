const express = require('express');

const app = express();


// 크롬에 'localhost:컨테이너의 포트번호' 입력하면, 그 때 화면에 뜨는 문자.
app.get('/', (req, res) => {
    res.send("How are you doing")
});




// [ 44강 ]

// '컨테이너 내부의 포트번호를 8080'이라고 설정해준 것임.
// 꼭 8080일 필요 없음. 내 임의대로 설정 가능함.
// 대신, vscode의 'index.js 파일' 내부에서 'app.listen(8080, ...)'에서의 8080이 바로 '컨테이너의 포트번호' 이기에, 
// 이 포트번호를 그에 맞춰 변경시켜줘야 함.
app.listen(8080, () => {
    console.log('Listening on port 8080')
});