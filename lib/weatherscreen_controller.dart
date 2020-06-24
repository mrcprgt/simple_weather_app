//Check for icons
String checkIcon(List jsonData) {
  switch (jsonData[1]["weather"][0]["icon"]) {
    case "01d":
      return "http://openweathermap.org/img/wn/01d@4x.png";
      break;
    case "02d":
      return "http://openweathermap.org/img/wn/02d@4x.png";
      break;
    case "03d":
      return "http://openweathermap.org/img/wn/03d@4x.png";
      break;
    case "04d":
      return "http://openweathermap.org/img/wn/04d@4x.png";
      break;
    case "09d":
      return "http://openweathermap.org/img/wn/09d@4x.png";
      break;
    case "10d":
      return "http://openweathermap.org/img/wn/10d@4x.png";
      break;
    case "11d":
      return "http://openweathermap.org/img/wn/11d@4x.png";
      break;
    case "13d":
      return "http://openweathermap.org/img/wn/13d@4x.png";
      break;
    case "50d":
      return "http://openweathermap.org/img/wn/50dd@4x.png";
      break;
    case "01n":
      return "http://openweathermap.org/img/wn/01n@4x.png";
      break;
    case "02n":
      return "http://openweathermap.org/img/wn/02n@4x.png";
      break;
    case "03n":
      return "http://openweathermap.org/img/wn/03n@4x.png";
      break;
    case "04n":
      return "http://openweathermap.org/img/wn/04n@4x.png";
      break;
    case "09n":
      return "http://openweathermap.org/img/wn/09n@4x.png";
      break;
    case "10n":
      return "http://openweathermap.org/img/wn/10n@4x.png";
      break;
    case "11n":
      return "http://openweathermap.org/img/wn/11n@4x.png";
      break;
    case "13n":
      return "http://openweathermap.org/img/wn/13n@4x.png";
      break;
    case "50n":
      return "http://openweathermap.org/img/wn/50n@4x.png";
      break;
    default:
  }
}
