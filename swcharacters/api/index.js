export default class API {
  static async getAll(dataType = 'people', pageNumber = 1) {
    if (pageNumber <= 0) {
      pageNumber = 1;
    }
    return API.fetch(`/${dataType}/?page=${pageNumber}`);
  }

  static async fetch(endPoint) {
    const fetchResults = await fetch(`https://swapi.co/api${endPoint}`);
    return fetchResults.json();
  }
}
