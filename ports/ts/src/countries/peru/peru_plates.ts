export const PeruPlates = {
  _stickerText(group: (key: string) => string): string | null {
    const register = group('register');
    const serial = group('serial');
    if (register === '' && serial === '') return null;
    return `${register}-${serial}`;
  },
};
