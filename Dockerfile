
# [ 45강 ]

# < simpleweb 프로젝트에서 vscode의 기존의 어떠한 구 Dockerfile의 소스코드('index.js 파일' 등의 내부 코드 등)를 내가 수정 변경한 경우 >


# < 아래의 도커 이미지 생성 과정 정리 >

# 순서1) FROM node:14-alpine
#       : 기본 이미지 선택. FROM 명령어를 사용해 Dockerfile의 베이스 이미지로 Node.js 14가 설치된 Alpine Linux를 지정함.
#         즉, 이제 이 베이스 이미지를 기반으로 컨테이너 빌드를 시작함.
# 순서2) COPY ./package.json ./
# 순서3) RUN npm install
#       : 위에서의 명령어 COPY에 의해 컨테이너 내부로 복사된 파일 중 'package.json'에 명시된 종속성(dependencies)을 설치하는 작업을 수행함.
# 순서4) COPY ./ ./
#       : '빌드 컨텍스트(= Dockerfile의 디렉토리) 내의 현재 호스트 디렉토리에 있는 모든 파일과 모든 폴더'를 '도커 이미지에 복사 붙여넣기'함.
#       단, 저 위에서 먼저 'COPY ./package.json'을 실행시켜서, 애플리케이션 실행에 필요한 의존성을 먼저 컨테이너에 따라 포함시켰기 때문에,
#       지금 여기 단계에서의 'COPY ./ ./'는, 이제 'package.json'을 제외한 기존의 어떠한 구 Dockerfile의 내부 코드들을 수정한
#       로컬 디렉토리에 남아있는 파일과 폴더들('index.js' 등)을 여기서 도커 이미지의 작업 디렉토리로 복사시킴.
#       그리고, 이후 나중에 터미널에서 이 도커 이미지를 빌드할 때, 이 계층만 따로 빌드하는 것임.
#       cf) 'Host OS'에서의 '.'는 'Dockerfile의 현재 위치'를 나타내고,
#           '컨테이너'에서의 './'는 '작업 디렉토리'를 의미함.
# 순서4) 최종적으로 CMD 명령어를 사용하여 컨테이너가 시작되면 기본적으로 실행될 명령어를 설정함.
#        여기에서는 컨테이너가 시작될 때마다 'npm-start'를 실행함.

# =========================================================================================================



# < FROM node:14-alpine >

# - 베이스 이미지 node:14 
#   : 기본 이미지
# - 베이스 이미지 node:14-alpine
#   : 경량화된 버전(빠른 다운로드와 설치, 작은 이미지 크기를 제공함)

# Specify a base image

FROM node:14-alpine


# =========================================================================================================


# < WORKDIR /usr/app >

# - 사용법: WORKDIR [path]
# - 'path'에 지정된 경로를 이제 그 컨테이너의 '작업 디렉토리'로 설정함. 
#   이 때, 기존의 경로가 이미 존재하지 않으면, 새로운 작업 디렉토리를 생성됨.
#   이미 지정된 경로가 있다면, 해당 경로를 작업 디렉토리로 사용함.
# - WORKDIR은 이후 Dockerfile에서 실행되는 COPY, RUN, CMD, ENTRYPOINT, ADD등의 명령어들이 실행되는 '기본 작업 디렉토리'를 설정하는 기능임.
# - 현재 컨테이너의 '작업 디렉토리'를 '/usr/app'으로 설정하는 명령어.
#   이후의 명령어에서 '기준 경로'로 사용됨.  
#   '기준 경로'가 되기 때문에 저 아래의 'COPY 명령어'에서 두 번째 './'가 바로 여기서 만든 '작업 디렉토리'가 됨.

WORKDIR /usr/app



# =========================================================================================================


# [ 47강 ]

# - 기존의 어떠한 구 Dockerfile의 소스코드('index.js 파일' 등의 내부 코드 등)를 내가 수정 변경한 경우!!!

# < COPY ./package.json ./ >

# - 현재 호스트 머신(=내 로컬 컴퓨터) 디렉토리의 'package.json' 파일을, 도커 컨테이너의 이미지 빌드에 포함(복사)시키는 것임.
#   'package.json' 파일은 애플리케이션의 모듈 정보, 의존성 정보를 포함하고 있어서, 이후 단계에서 필요함.
# - 기존의 어떠한 구 Dockerfile의 내부 코드들을 수정하고, 터미널로 돌아가서 
#   수정된 이 도커 이미지 Dockerfile '전체'를 'COPY ./ ./'를 통해 전체 재빌드하고 재시작 재실행하면,
#   아무런 수정도 하지 않은 package.json의 의존성까지 처음부터 다시 다 재설치하는 것이고, 이는 불필요한 시간과 리소스를 소모함.
# - 도커 이미지 빌드 과정에서 위와 같은 불필요한 작업을 줄여서 빌드 속도, 시간, 효율성을 개선하기 위해, 
#   의존성 코드만 담고 있는 package.json 파일만 '먼저 우선하여 빌드해놓으면', 의존성 변경이 발생하지 않는 한, 
#   이후 빌드에서 이 계층(레이어)를 재사용할 수 있음.
#   아무론 코드의 변경도 없는 package.json만 따로 먼저 별개로 떼어내서 '작업 디렉토리'로 복사(포함)시켜두고,
#   바로 아래에 연속해서 나오는 npm install을 터미널에서 순서대로 실행되게 만들어서, 
#   그 의존성들만 먼저 별개로 따로 빠르게 설치해주어서, '소스 코드의 변경'이 의존성 설치에 영향을 주지 않도록 하는 것이 이 목적임

COPY ./package.json ./


# =========================================================================================================


# < RUN npm install >

# wsl에서 'npm install이 내장되어 포함된 node:14-alpine'을 가져와서 이 Dockerfile을 빌드할 때(=docker build .), 
# Dockerfile 이외의 파일들, 즉 여기서는 'package.json'과 'index.js'과 같은 파일들은 기본값으로 같이 빌드되어 컨테이너 안으로 들어가지 않음!
# 따라서, 'npm install 명령어'를 실행하여 Node Package Modules(Manager)을 설치하고, 이를 통해 package.json에서 의존성 목록들을 읽어오고,
# 해당 모듈들(의존성이 설치된 모듈들)을 Node.js 애플리케이션에서 사용할 수 있도록(=컨테이너 내부로 불러들일 수 있도록) 컨테이너 내부에 설치함.
# 이 단계에서 필요한 라이브러리 등이 도커 이미지에 포함됨.

# - 여기서는, 위에서 현재 컨테이너 이미지 빌드의 작업 디렉토리에 포함(복사)시킨 'package.json' 파일에 포함된 의존성을 설치시키기 위해
#   npm install 명령어를 실행시킴.
#   이렇게 함으로써, Node.js 애플리케이션에 필요한 모듈을 컨테이너에 설치할 수 있음.
#   (=애플리케이션 실행에 필요한 라이브러리와 패키지를 도커 이미지에 추가하는 것임.)
# - 즉, npm install은 package.json의 의존성 설치만을 담당하고 있는 것이다! 
#   npm install은 기타 index.js 와 같은 파일과는 아무런 영향을 서로 주고받지 않는다!

# Install some dependencies

RUN npm install


# =========================================================================================================


# < COPY ./ ./ >

# - Dockerfile을 파싱 시, Docker 빌드 환경은 '명령어 COPY'를 만나면 이를 처리함.
#   처리 과정에서 원본 경로의 파일과 디렉토리를, 대상 경로에 복사하고 새 도커 이미지 레이어에 기록함.
#   이를 통해 필요한 파일들이 도커 이미지에 포함되어 빌드됨.
# - 여기서는, '현재 호스트 디렉토리의 모든 파일과 폴더(= 첫 번째 './')'를 '도커 컨테이너 내부의 작업 디렉토리(= 저 위에서 만든 'usr/app')'로
#   복사한다!!! 라는 의미임.
# - 형식: COPY ['내 로컬머신에서'의 복사'할'파일, 디렉토리의 경로] ['컨테이너' 내부에서의 그 복사된 파일, 디렉토리가 붙여넣기 될 경로]
# - e.g)
#   ~ COPY app.js / app: '현재 내 로컬 컴퓨터의 디렉토리에 있는 파일 app.js'를 '도커 이미지의 경로 /app'에 복사 붙여넣기 한다.
#   ~ COPY ./src /app/src: 내 로컬 컴퓨터의 해당 폴더의 디렉토리를 전체 복사해서 도커 이미지의 경로 /app/src에 복사 붙여넣기 한다.
#   ~ COPY pakckage.json /app: 외부 종속성을 복사 붙여넣기

# *****중요*****
# - 저 위에서 먼저 'COPY ./package.json'을 실행시켜서, 애플리케이션 실행에 필요한 의존성을 먼저 컨테이너에 따라 포함시켰기 때문에,
#   지금 여기 단계에서의 'COPY ./ ./'는, 이제 'package.json'을 제외한 기존의 어떠한 구 Dockerfile의 내부 코드들을 수정한
#   로컬 디렉토리에 남아있는 파일(소스코드를 담고 있는 'index.js' 등)과 폴더들을 여기서 도커 이미지의 작업 디렉토리로 복사시킴.
#   그리고, 이후 나중에 터미널에서 이 도커 이미지를 빌드할 때, 이 계층만 따로 빌드하는 것임.

COPY ./ ./


# =========================================================================================================


# < CMD ["npm", "start"] >

# - 도커 컨테이너가 시작될 때마다 기본적으로 'npm start'를 실행시켜주는 명령어.
# - 이를 통해 웹 서버가 시작됨. 즉, 이 명령어를 통해 이 애플리케이션에서 필요한 서버가 실행됨.

# Defalut command

CMD ["npm", "start"]