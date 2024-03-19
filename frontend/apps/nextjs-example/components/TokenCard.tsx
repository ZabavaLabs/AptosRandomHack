import { MediaRenderer } from "@thirdweb-dev/react";

export default function TokenCard(props: {
  tokenAddress: string;
  collectionAddress: string;
  tokenUri: string;
  tokenName: string;
  clickCallback: (tokenAddress: any) => void;
}) {
  const { tokenAddress, collectionAddress, tokenUri, tokenName, clickCallback } = props;
  return (
    <button
      onClick={() => clickCallback({ tokenAddress, tokenUri, tokenName })}
      className="flex flex-col items-center justify-center w-full h-auto rounded-lg translucent-background flex-wrap p-8 focus:bg-gray-900">
      < MediaRenderer
        src={`${tokenUri}`}
        alt="Token Image"
        className='flex h-auto w-40'
      />
      <p className="text-white mt-4">Name: {tokenName}</p>
      <p className="text-white w-full mt-4 text-center overflow-hidden">Address: {tokenAddress}</p>
    </button>
  );
}
