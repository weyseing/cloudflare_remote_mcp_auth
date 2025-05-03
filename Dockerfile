FROM node:lts 

# working dir
WORKDIR /usr/src/app

# install node packages
COPY package*.json ./
RUN npm install

# app files
COPY . .

EXPOSE 3000
CMD ["tail", "-f", "/dev/null"]