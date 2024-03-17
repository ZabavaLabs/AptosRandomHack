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
      className="flex flex-col items-center justify-center w-full h-auto rounded-lg bg-slate-700 flex-wrap p-4 focus:bg-blue-900">
      < MediaRenderer
        src={`${tokenUri}`}
        alt="Token Image"
        className='flex h-auto w-40'
      />
      <p className="text-white ">Name: {tokenName}</p>
      <p className="text-white w-full text-center overflow-hidden">Address: {tokenAddress}</p>
    </button>
  );
}
