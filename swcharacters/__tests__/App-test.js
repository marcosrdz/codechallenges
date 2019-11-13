/**
 * @format
 */

import API from '../api';
const mockPeopleResponse = require('./mockPeopleResponse.json');

beforeEach(() => {
  fetch.resetMocks();
});

test('mock JSON response', () => {
  fetch.mockResponseOnce(JSON.stringify(mockPeopleResponse));
  const onResponse = jest.fn();
  const onError = jest.fn();

  return API.getAll()
    .then(onResponse)
    .catch(onError)
    .finally(() => {
      expect(onResponse).toHaveBeenCalled();
      expect(onError).not.toHaveBeenCalled();
      const count = onResponse.mock.calls[0][0].count;
      expect(count).toEqual(87);
    });
});
